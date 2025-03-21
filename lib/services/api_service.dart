import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../network/config.dart';
import 'cache_service.dart';
import 'dart:collection';

// Isolate worker for API requests
Future<Map<String, dynamic>> _makeRequestInIsolate(
    Map<String, dynamic> params) async {
  final client = params['isDebug']
      ? IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true)
      : http.Client();

  try {
    final response = await client
        .post(
          Uri.parse(params['endpoint']),
          headers: params['headers'],
          body: json.encode(params['body']),
        )
        .timeout(Duration(milliseconds: params['timeout']));

    final responseBody = response.body;

    // Check for HTML response which might indicate auth issues
    if (responseBody.trim().toLowerCase().startsWith('<!doctype html') ||
        responseBody.trim().toLowerCase().startsWith('<html')) {
      throw Exception(
          'Received HTML response instead of JSON. Possible authentication issue.');
    }

    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.statusCode}');
    }

    return json.decode(responseBody);
  } finally {
    client.close();
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final http.Client _client;

  // Request coalescing
  final _pendingRequests = <String, Future<Map<String, dynamic>>>{};

  // Request queue
  final _requestQueue = Queue<Future<void> Function()>();
  bool _processing = false;
  static const _maxConcurrentRequests = 4;
  int _activeRequests = 0;

  ApiService._internal() {
    // In development, use a client that accepts self-signed certificates
    if (kDebugMode) {
      final httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      _client = IOClient(httpClient);
    } else {
      _client = http.Client();
    }
  }

  // Process queue with concurrency control
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

  // Generate cache key from request details
  String _generateCacheKey(String endpoint, Map<String, dynamic> body) {
    return '${endpoint}_${json.encode(body)}';
  }

  // Check if response is HTML
  bool _isHtmlResponse(String body) {
    return body.trim().toLowerCase().startsWith('<!doctype html') ||
        body.trim().toLowerCase().startsWith('<html');
  }

  // Make API call with caching and request coalescing
  Future<Map<String, dynamic>> makeRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(endpoint, body);

    // Check for pending request with same cache key
    if (_pendingRequests.containsKey(cacheKey)) {
      debugPrint('📦 Reusing pending request for $endpoint');
      return _pendingRequests[cacheKey]!;
    }

    // Create the request function
    Future<Map<String, dynamic>> requestFunction() async {
      try {
        // Check cache first if not forcing refresh
        if (!forceRefresh && cacheDuration != null) {
          final cachedData = await CacheService.getCachedData(cacheKey);
          if (cachedData != null) {
            debugPrint('✅ Cache hit for $endpoint');
            return cachedData;
          }
        }

        // Make API call in isolate
        final response = await compute(_makeRequestInIsolate, {
          'endpoint': endpoint,
          'headers': {
            ...ApiConfig.headers,
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json',
          },
          'body': body,
          'timeout': ApiConfig.connectionTimeout,
          'isDebug': kDebugMode,
        });

        // Cache successful response
        if (cacheDuration != null) {
          await CacheService.cacheData(
            key: cacheKey,
            data: response,
            duration: cacheDuration,
          );
        }

        return response;
      } catch (e) {
        debugPrint('❌ API Error for $endpoint: $e');

        // Try cache on error
        if (cacheDuration != null) {
          final cachedData = await CacheService.getCachedData(cacheKey);
          if (cachedData != null) {
            debugPrint('⚠️ Using cached data after error for $endpoint');
            return {
              ...cachedData,
              'fromCache': true,
              'error': e.toString(),
            };
          }
        }

        return {
          'status': 'error',
          'message': 'Failed to connect to server',
          'error': e.toString(),
        };
      } finally {
        // Remove from pending requests
        _pendingRequests.remove(cacheKey);
      }
    }

    // Add to pending requests and queue
    final future = requestFunction();
    _pendingRequests[cacheKey] = future;

    _requestQueue.add(() => future);
    _processQueue();

    return future;
  }

  // Batch multiple API calls with concurrency control
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

  // Clean up resources
  void dispose() {
    _client.close();
    _pendingRequests.clear();
    _requestQueue.clear();
  }
}
