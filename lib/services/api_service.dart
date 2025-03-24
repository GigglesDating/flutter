import 'package:http/io_client.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/config.dart';
import 'cache_service.dart';
import 'dart:collection';

// Create HTTP client with proper SSL handling
HttpClient _createHttpClient() {
  final client = HttpClient();
  if (kDebugMode) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  }
  return client;
}

// Isolate function for making HTTP requests
Future<Map<String, dynamic>> _makeRequestInIsolate(
    Map<String, dynamic> params) async {
  final httpClient = _createHttpClient();
  final client = IOClient(httpClient);

  try {
    final endpoint = params['endpoint'] as String;
    final headers = params['headers'] as Map<String, String>;
    final body = params['body'] as Map<String, dynamic>;
    final timeout = params['timeout'] as int;

    debugPrint('Making request to: $endpoint');
    debugPrint('Headers: $headers');
    debugPrint('Body: $body');

    final response = await client
        .post(
          Uri.parse(endpoint),
          headers: headers,
          body: json.encode(body),
        )
        .timeout(Duration(milliseconds: timeout));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      return {
        'status': 'error',
        'message': 'Server error: ${response.statusCode}',
        'data': null
      };
    }
  } catch (e) {
    debugPrint('Request error in isolate: $e');
    return {'status': 'error', 'message': e.toString(), 'data': null};
  } finally {
    client.close();
    httpClient.close();
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final IOClient _client;
  final _pendingRequests = <String, Future<Map<String, dynamic>>>{};
  final _requestQueue = Queue<Future<void> Function()>();
  bool _processing = false;
  static const _maxConcurrentRequests = 4;
  int _activeRequests = 0;
  bool _isInitialized = false;

  ApiService._internal() {
    final httpClient = _createHttpClient();
    _client = IOClient(httpClient);
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('ApiService already initialized');
      return;
    }

    try {
      await CacheService.init();
      _isInitialized = true;
      debugPrint('ApiService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ApiService: $e');
    }
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;

    while (_requestQueue.isNotEmpty) {
      if (_activeRequests >= _maxConcurrentRequests) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      final request = _requestQueue.removeFirst();
      _activeRequests++;

      try {
        await request();
      } finally {
        _activeRequests--;
      }
    }

    _processing = false;
  }

  String _generateCacheKey(String endpoint, Map<String, dynamic> body) {
    final functionName = body['function'] as String?;
    final uuid = body['uuid'] as String?;
    final key = functionName != null
        ? '${endpoint}_${functionName}_${uuid ?? ""}_${json.encode(body)}'
        : '${endpoint}_${json.encode(body)}';
    return key;
  }

  Future<Map<String, dynamic>> makeRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final cacheKey = _generateCacheKey(endpoint, body);

    if (_pendingRequests.containsKey(cacheKey)) {
      return _pendingRequests[cacheKey]!;
    }

    Future<Map<String, dynamic>> requestFunction() async {
      try {
        if (!forceRefresh && cacheDuration != null) {
          final cachedData = await CacheService.getCachedData(cacheKey);
          if (cachedData != null) {
            return cachedData;
          }
        }

        final response = await compute(_makeRequestInIsolate, {
          'endpoint': endpoint,
          'headers': ApiConfig.headers,
          'body': body,
          'timeout': 30000, // 30 seconds timeout
        });

        if (response['status'] == 'success' && cacheDuration != null) {
          await CacheService.cacheData(
            key: cacheKey,
            data: response,
            duration: cacheDuration,
          );
        }

        return response;
      } catch (e) {
        debugPrint('Error in request function: $e');
        return {
          'status': 'error',
          'message': e.toString(),
          'data': null,
        };
      } finally {
        _pendingRequests.remove(cacheKey);
      }
    }

    final future = requestFunction();
    _pendingRequests[cacheKey] = future;

    _requestQueue.add(() => future);
    _processQueue();

    return future;
  }

  Future<List<Map<String, dynamic>>> batchRequests({
    required List<Map<String, dynamic>> requests,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final futures = requests.map((request) => makeRequest(
          endpoint: request['endpoint'],
          body: request['body'],
          cacheDuration: cacheDuration,
          forceRefresh: forceRefresh,
        ));

    try {
      return await Future.wait(futures);
    } catch (e) {
      debugPrint('Error in batch request: $e');
      return List.generate(
        requests.length,
        (index) => {
          'status': 'error',
          'message': 'Batch request failed',
          'data': null,
        },
      );
    }
  }

  void dispose() {
    _client.close();
    _pendingRequests.clear();
    _requestQueue.clear();
    _isInitialized = false;
  }
}
