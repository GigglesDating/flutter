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
    debugPrint('Making request to: ${params['endpoint']}');
    debugPrint('Request body: ${params['body']}');

    final response = await client
        .post(
          Uri.parse(params['endpoint']),
          headers: params['headers'],
          body: json.encode(params['body']),
        )
        .timeout(Duration(milliseconds: params['timeout']));

    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

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
      debugPrint('Error parsing response: $e');
      return {
        'status': 'error',
        'message': 'Invalid response format',
        'data': null
      };
    }

    if (response.statusCode >= 400) {
      debugPrint('Error response: ${jsonResponse['message']}');
      return {
        'status': 'error',
        'message': jsonResponse['message'] ?? 'Server error',
        'data': null
      };
    }

    return jsonResponse;
  } catch (e) {
    debugPrint('Request error: $e');
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
      // Wait for cache service to be ready
      await CacheService.init();

      _isInitialized = true;
      debugPrint('ApiService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ApiService: $e');
      // Don't rethrow - we want the service to continue even if initialization fails
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
      } catch (e) {
        debugPrint('Error processing request: $e');
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

    debugPrint('Generated cache key: $key');
    return key;
  }

  Future<Map<String, dynamic>> makeRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    // Ensure service is initialized
    if (!_isInitialized) {
      await initialize();
    }

    final cacheKey = _generateCacheKey(endpoint, body);

    if (_pendingRequests.containsKey(cacheKey)) {
      debugPrint('Using pending request for key: $cacheKey');
      return _pendingRequests[cacheKey]!;
    }

    Future<Map<String, dynamic>> requestFunction() async {
      try {
        if (!forceRefresh && cacheDuration != null) {
          try {
            debugPrint('Checking cache for key: $cacheKey');
            final cachedData = await CacheService.getCachedData(cacheKey);
            if (cachedData != null) {
              debugPrint('Cache hit for key: $cacheKey');
              return cachedData;
            }
            debugPrint('Cache miss for key: $cacheKey');
          } catch (cacheError) {
            debugPrint('Cache error (non-fatal): $cacheError');
            // Continue with API request even if cache fails
          }
        }

        debugPrint('Making API request for key: $cacheKey');
        final response = await compute(_makeRequestInIsolate, {
          'endpoint': endpoint,
          'headers': ApiConfig.headers,
          'body': body,
          'timeout': ApiConfig.connectionTimeout.inMilliseconds,
        });

        if (response['status'] == 'success' && cacheDuration != null) {
          try {
            debugPrint('Caching successful response for key: $cacheKey');
            await CacheService.cacheData(
              key: cacheKey,
              data: response,
              duration: cacheDuration,
            );
          } catch (cacheError) {
            debugPrint('Cache error (non-fatal): $cacheError');
            // Continue even if caching fails
          }
        }

        return response;
      } catch (e) {
        debugPrint('Error in request function: $e');
        if (cacheDuration != null) {
          try {
            final cachedData = await CacheService.getCachedData(cacheKey);
            if (cachedData != null) {
              debugPrint('Using cached data after error for key: $cacheKey');
              return {
                ...cachedData,
                'fromCache': true,
                'error': e.toString(),
              };
            }
          } catch (cacheError) {
            debugPrint('Error accessing cache: $cacheError');
          }
        }

        return {
          'status': 'error',
          'message': e.toString(),
          'data': null,
          'error': e.toString(),
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
    debugPrint('Processing batch request with ${requests.length} items');
    final futures = requests.map((request) => makeRequest(
          endpoint: request['endpoint'],
          body: request['body'],
          cacheDuration: cacheDuration,
          forceRefresh: forceRefresh,
        ));

    try {
      final results = await Future.wait(futures);
      debugPrint('Batch request completed successfully');
      return results;
    } catch (e) {
      debugPrint('Error in batch request: $e');
      return List.generate(
        requests.length,
        (index) => {
          'status': 'error',
          'message': 'Batch request failed',
          'data': null,
          'error': e.toString(),
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
