import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/utils/snip_cache_manager.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class CacheService {
  static const String apiCacheBox = 'apiCache';
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static SnipCacheManager? _snipCacheManager;
  static bool _isInitialized = false;

  // Initialize Hive and open boxes
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);

      if (!Hive.isBoxOpen(apiCacheBox)) {
        await Hive.openBox(apiCacheBox);
      }

      _snipCacheManager = SnipCacheManager();
      _isInitialized = true;
      debugPrint('CacheService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing CacheService: $e');
      // Create a new box if there's an error with the existing one
      try {
        await Hive.deleteBoxFromDisk(apiCacheBox);
        await Hive.openBox(apiCacheBox);
        _isInitialized = true;
        debugPrint('CacheService recovered after error');
      } catch (e) {
        debugPrint('Fatal error initializing CacheService: $e');
        rethrow;
      }
    }
  }

  // Cache data with expiration
  static Future<void> cacheData({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    final box = Hive.box(apiCacheBox);
    final expiryTime = DateTime.now().add(duration ?? defaultCacheDuration);

    final cacheData = {
      'data': data,
      'expiry': expiryTime.toIso8601String(),
    };

    await box.put(key, json.encode(cacheData));
  }

  // Get cached data if not expired
  static Future<dynamic> getCachedData(String key) async {
    final box = Hive.box(apiCacheBox);
    final cachedJson = box.get(key);

    if (cachedJson == null) return null;

    try {
      final cached = json.decode(cachedJson);
      final expiry = DateTime.parse(cached['expiry']);

      if (DateTime.now().isBefore(expiry)) {
        return cached['data'];
      } else {
        // Clean up expired cache
        await box.delete(key);
        return null;
      }
    } catch (e) {
      debugPrint('Error reading cache: $e');
      return null;
    }
  }

  // Clear specific cache
  static Future<void> clearCache(String key) async {
    final box = Hive.box(apiCacheBox);
    await box.delete(key);
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    final box = Hive.box(apiCacheBox);
    await box.clear();
    await _snipCacheManager?.emptyCache();
  }

  // Clean expired cache entries
  static Future<void> cleanExpiredCache() async {
    final box = Hive.box(apiCacheBox);
    final keys = box.keys.toList();

    for (var key in keys) {
      final cachedJson = box.get(key);
      if (cachedJson != null) {
        try {
          final cached = json.decode(cachedJson);
          final expiry = DateTime.parse(cached['expiry']);

          if (DateTime.now().isAfter(expiry)) {
            await box.delete(key);
          }
        } catch (e) {
          debugPrint('Error cleaning cache: $e');
          await box.delete(key);
        }
      }
    }

    // Clean SnipCacheManager if needed
    await _snipCacheManager?.cleanCacheIfNeeded();
  }

  // Get combined cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    final box = Hive.box(apiCacheBox);
    int totalEntries = box.length;
    int expiredEntries = 0;
    int validEntries = 0;

    for (var key in box.keys) {
      final cachedJson = box.get(key);
      if (cachedJson != null) {
        try {
          final cached = json.decode(cachedJson);
          final expiry = DateTime.parse(cached['expiry']);

          if (DateTime.now().isAfter(expiry)) {
            expiredEntries++;
          } else {
            validEntries++;
          }
        } catch (e) {
          expiredEntries++;
        }
      }
    }

    // Get SnipCacheManager analytics
    final snipAnalytics = _snipCacheManager?.analytics;

    return {
      'apiCache': {
        'totalEntries': totalEntries,
        'validEntries': validEntries,
        'expiredEntries': expiredEntries,
      },
      'mediaCache': snipAnalytics != null
          ? {
              'hitCount': snipAnalytics.hitCount,
              'missCount': snipAnalytics.missCount,
              'evictionCount': snipAnalytics.evictionCount,
              'hitRate': snipAnalytics.hitRate,
              'totalSize': snipAnalytics.totalSize,
              'itemCount': snipAnalytics.itemCount,
              'priorityDistribution': snipAnalytics.priorityDistribution,
            }
          : null,
    };
  }

  // Preload media content
  static Future<void> preloadMedia({
    List<String> videoUrls = const [],
    List<String> thumbnailUrls = const [],
    CachePriority priority = CachePriority.medium,
  }) async {
    if (_snipCacheManager == null) return;

    await _snipCacheManager!.preloadBatch(
      videoUrls: videoUrls,
      thumbnailUrls: thumbnailUrls,
      videoPriority: priority,
      thumbnailPriority: CachePriority.low,
    );
  }

  // Clean media cache
  static Future<void> cleanMediaCache() async {
    await _snipCacheManager?.emptyCache();
  }
}
