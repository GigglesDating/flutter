import 'package:http/io_client.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/config.dart';
import 'cache_service.dart';
import 'dart:collection';

HttpClient _createHttpClient() {
  final client = HttpClient();
  if (kDebugMode) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  }
  return client;
}

Future<Map<String, dynamic>> _makeRequestInIsolate(
    Map<String, dynamic> params) async {
  final httpClient = _createHttpClient();
  final client = IOClient(httpClient);

  try {
    final response = await client
        .post(
          Uri.parse(params['endpoint']),
          headers: params['headers'],
          body: json.encode(params['body']),
        )
        .timeout(Duration(milliseconds: params['timeout']));

    if (response.body.isEmpty) {
      return {
        'status': 'error',
        'message': 'Empty response from server',
        'data': null
      };
    }

    Map<String, dynamic> jsonResponse;
    try {
      jsonResponse = json.decode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Invalid response format',
        'data': null
      };
    }

    if (response.statusCode >= 400) {
      return {
        'status': 'error',
        'message': jsonResponse['message'] ?? 'Server error',
        'data': null
      };
    }

    return jsonResponse;
  } catch (e) {
    if (e is TimeoutException) {
      return {'status': 'error', 'message': 'Request timed out', 'data': null};
    }
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

  ApiService._internal() {
    final httpClient = _createHttpClient();
    _client = IOClient(httpClient);
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
    return functionName != null
        ? '${endpoint}_${functionName}_${uuid ?? ""}_${json.encode(body)}'
        : '${endpoint}_${json.encode(body)}';
  }

  Future<Map<String, dynamic>> makeRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
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
          'timeout': ApiConfig.connectionTimeout.inMilliseconds,
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
        if (cacheDuration != null) {
          final cachedData = await CacheService.getCachedData(cacheKey);
          if (cachedData != null) {
            return {
              ...cachedData,
              'fromCache': true,
              'error': e.toString(),
            };
          }
        }

        return {'status': 'error', 'message': e.toString(), 'data': null};
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

    return await Future.wait(futures);
  }

  void dispose() {
    _client.close();
    _pendingRequests.clear();
    _requestQueue.clear();
  }
}
