import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/utils/snip_cache_manager.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  // Box names
  static const String apiCacheBox = 'apiCache';
  static const String mediaCacheBox = 'mediaCache';

  // Cache durations
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(hours: 1);
  static const Duration longCache = Duration(days: 1);
  static const Duration defaultCacheDuration = mediumCache;

  // Cache limits
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxItemSize = 5 * 1024 * 1024; // 5MB

  // State management
  static SnipCacheManager? _snipCacheManager;
  static bool _isInitialized = false;
  static DateTime _lastCleanup = DateTime.now();
  static const Duration cleanupInterval = Duration(hours: 6);

  // Initialize the cache service
  static Future<void> init() async {
    if (_isInitialized) {
      debugPrint('Cache service already initialized');
      return;
    }

    try {
      debugPrint('Starting cache service initialization...');

      // Initialize API cache box
      await _initBox(apiCacheBox);

      // Initialize media cache box
      await _initBox(mediaCacheBox);

      // Initialize SnipCacheManager
      _snipCacheManager = SnipCacheManager();

      // Perform initial maintenance
      await _performMaintenanceIfNeeded();

      _isInitialized = true;
      debugPrint('Cache service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing cache service: $e');
      await _recoverFromError();
    }
  }

  // Initialize a specific box
  static Future<void> _initBox(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        debugPrint('Opening box: $boxName');
        await Hive.openBox(boxName);
      }
      debugPrint('Box $boxName initialized successfully');
    } catch (e) {
      debugPrint('Error opening box $boxName: $e');
      await _recoverBox(boxName);
    }
  }

  // Recover from initialization error
  static Future<void> _recoverFromError() async {
    try {
      debugPrint('Attempting to recover cache service...');

      // Try to recover API cache box
      await _recoverBox(apiCacheBox);

      // Try to recover media cache box
      await _recoverBox(mediaCacheBox);

      // Reinitialize SnipCacheManager
      _snipCacheManager = SnipCacheManager();

      _isInitialized = true;
      debugPrint('Cache service recovered successfully');
    } catch (e) {
      debugPrint('Failed to recover cache service: $e');
      // Don't rethrow - allow the app to continue without cache
    }
  }

  // Recover a specific box
  static Future<void> _recoverBox(String boxName) async {
    try {
      debugPrint('Attempting to recover box: $boxName');

      // Close box if open
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }

      // Try to delete and recreate the box
      try {
        await Hive.deleteBoxFromDisk(boxName);
        debugPrint('Deleted box from disk: $boxName');
      } catch (e) {
        debugPrint('Error deleting box from disk: $e');
      }

      // Open the box
      await Hive.openBox(boxName);
      debugPrint('Successfully recovered box: $boxName');
    } catch (e) {
      debugPrint('Error recovering box $boxName: $e');
      // Don't rethrow - allow the app to continue without this box
    }
  }

  // Cache data with proper error handling
  static Future<void> cacheData({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    if (!_isInitialized) {
      debugPrint('Cache service not initialized, attempting to initialize...');
      await init();
    }

    try {
      final box = Hive.box(apiCacheBox);
      final expiryTime = DateTime.now().add(duration ?? defaultCacheDuration);

      // Check data size
      final dataSize = utf8.encode(json.encode(data)).length;
      if (dataSize > maxItemSize) {
        debugPrint('Cache item too large: $dataSize bytes');
        return;
      }

      final cacheData = {
        'data': data,
        'expiry': expiryTime.toIso8601String(),
        'size': dataSize,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await box.put(key, json.encode(cacheData));
      debugPrint('Successfully cached data for key: $key');
    } catch (e) {
      debugPrint('Error caching data: $e');
      // Silently fail on cache write error
    }

    await _performMaintenanceIfNeeded();
  }

  // Get cached data with proper error handling
  static Future<dynamic> getCachedData(String key) async {
    if (!_isInitialized) {
      debugPrint('Cache service not initialized, attempting to initialize...');
      await init();
    }

    try {
      final box = Hive.box(apiCacheBox);
      final cachedJson = box.get(key);

      if (cachedJson == null) {
        debugPrint('Cache miss for key: $key');
        return null;
      }

      final cached = json.decode(cachedJson);
      final expiry = DateTime.parse(cached['expiry']);

      if (DateTime.now().isBefore(expiry)) {
        debugPrint('Cache hit for key: $key');
        return cached['data'];
      } else {
        debugPrint('Cache expired for key: $key');
        await box.delete(key);
        return null;
      }
    } catch (e) {
      debugPrint('Error retrieving cached data: $e');
      return null;
    }
  }

  // Clear specific cache
  static Future<void> clearCache(String key) async {
    if (!_isInitialized) {
      debugPrint('Cache service not initialized, attempting to initialize...');
      await init();
    }

    try {
      final box = Hive.box(apiCacheBox);
      await box.delete(key);
      debugPrint('Cleared cache for key: $key');
    } catch (e) {
      debugPrint('Error clearing cache for key $key: $e');
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    if (!_isInitialized) {
      debugPrint('Cache service not initialized, attempting to initialize...');
      await init();
    }

    try {
      final box = Hive.box(apiCacheBox);
      await box.clear();
      await _snipCacheManager?.emptyCache();
      debugPrint('Cleared all cache');
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  // Perform maintenance if needed
  static Future<void> _performMaintenanceIfNeeded() async {
    if (DateTime.now().difference(_lastCleanup) < cleanupInterval) {
      return;
    }

    try {
      final box = Hive.box(apiCacheBox);
      final keys = box.keys.toList();
      int totalSize = 0;
      final itemsToDelete = <dynamic>[];

      for (var key in keys) {
        final cachedJson = box.get(key);
        if (cachedJson != null) {
          try {
            final cached = json.decode(cachedJson);
            final expiry = DateTime.parse(cached['expiry']);
            final size = (cached['size'] ?? 0) as int;

            if (DateTime.now().isAfter(expiry)) {
              itemsToDelete.add(key);
            } else {
              totalSize += size;
            }
          } catch (e) {
            itemsToDelete.add(key);
          }
        }
      }

      // Delete expired items
      for (var key in itemsToDelete) {
        await box.delete(key);
      }

      // Handle size limits
      if (totalSize > maxCacheSize) {
        final items = keys
            .where((k) => !itemsToDelete.contains(k))
            .map((k) => {
                  'key': k,
                  'timestamp': json.decode(box.get(k))['timestamp'],
                })
            .toList();

        items.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        for (var item in items) {
          if (totalSize <= maxCacheSize) break;
          final key = item['key'];
          final size = (json.decode(box.get(key))['size'] ?? 0) as int;
          await box.delete(key);
          totalSize -= size;
        }
      }

      await _snipCacheManager?.cleanCacheIfNeeded();
      _lastCleanup = DateTime.now();
      debugPrint('Cache maintenance completed');
    } catch (e) {
      debugPrint('Error during cache maintenance: $e');
    }
  }

  // Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized) {
      debugPrint('Cache service not initialized, attempting to initialize...');
      await init();
    }

    try {
      final box = Hive.box(apiCacheBox);
      int totalEntries = box.length;
      int expiredEntries = 0;
      int validEntries = 0;
      int totalSize = 0;

      for (var key in box.keys) {
        final cachedJson = box.get(key);
        if (cachedJson != null) {
          try {
            final cached = json.decode(cachedJson);
            final expiry = DateTime.parse(cached['expiry']);
            final size = (cached['size'] ?? 0) as int;

            totalSize += size;
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

      final snipAnalytics = _snipCacheManager?.analytics;

      return {
        'apiCache': {
          'totalEntries': totalEntries,
          'validEntries': validEntries,
          'expiredEntries': expiredEntries,
          'totalSize': totalSize,
          'maxSize': maxCacheSize,
          'utilizationPercentage': ((totalSize / maxCacheSize) * 100).toInt(),
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
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return {
        'apiCache': {
          'totalEntries': 0,
          'validEntries': 0,
          'expiredEntries': 0,
          'totalSize': 0,
          'maxSize': maxCacheSize,
          'utilizationPercentage': 0,
        },
        'mediaCache': null,
      };
    }
  }

  // Media cache methods
  static Future<void> preloadMedia({
    List<String> videoUrls = const [],
    List<String> thumbnailUrls = const [],
    CachePriority priority = CachePriority.medium,
  }) async {
    if (_snipCacheManager == null) {
      debugPrint(
          'SnipCacheManager not initialized, attempting to initialize...');
      await init();
    }

    try {
      await _snipCacheManager!.preloadBatch(
        videoUrls: videoUrls,
        thumbnailUrls: thumbnailUrls,
        videoPriority: priority,
        thumbnailPriority: CachePriority.low,
      );
    } catch (e) {
      debugPrint('Error preloading media: $e');
    }
  }

  static Future<void> cleanMediaCache() async {
    if (_snipCacheManager == null) {
      debugPrint(
          'SnipCacheManager not initialized, attempting to initialize...');
      await init();
    }

    try {
      await _snipCacheManager?.emptyCache();
      debugPrint('Media cache cleaned');
    } catch (e) {
      debugPrint('Error cleaning media cache: $e');
    }
  }
}
