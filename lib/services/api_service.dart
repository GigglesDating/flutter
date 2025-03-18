import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/config.dart';
import 'cache_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  // Generate cache key from request details
  String _generateCacheKey(String endpoint, Map<String, dynamic> body) {
    return '${endpoint}_${json.encode(body)}';
  }

  // Make API call with caching
  Future<Map<String, dynamic>> makeRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(endpoint, body);

    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedData = await CacheService.getCachedData(cacheKey);
        if (cachedData != null) {
          debugPrint('Cache hit for $endpoint');
          return cachedData;
        }
      }

      // Make API call
      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: ApiConfig.headers,
            body: json.encode(body),
          )
          .timeout(
            Duration(milliseconds: ApiConfig.connectionTimeout),
          );

      // Parse response
      final decodedResponse = json.decode(response.body);

      // Cache successful responses
      if (response.statusCode == 200 || response.statusCode == 201) {
        await CacheService.cacheData(
          key: cacheKey,
          data: decodedResponse,
          duration: cacheDuration,
        );
      }

      return decodedResponse;
    } catch (e) {
      debugPrint('API Error for $endpoint: $e');

      // Check cache again in case of network error
      final cachedData = await CacheService.getCachedData(cacheKey);
      if (cachedData != null) {
        debugPrint('Using cached data after error for $endpoint');
        return {
          ...cachedData,
          'fromCache': true,
          'error': e.toString(),
        };
      }

      rethrow;
    }
  }

  // Batch multiple API calls
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
  }
}
