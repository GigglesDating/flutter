import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/utils/snip_cache_manager.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/foundation.dart';
import 'dart:io';

class CacheService {
  static const String apiCacheBox = 'apiCache';

  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(hours: 1);
  static const Duration longCache = Duration(days: 1);
  static const Duration defaultCacheDuration = mediumCache;

  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxItemSize = 5 * 1024 * 1024; // 5MB

  static SnipCacheManager? _snipCacheManager;
  static bool _isInitialized = false;
  static DateTime _lastCleanup = DateTime.now();
  static const Duration cleanupInterval = Duration(hours: 6);

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Get the application documents directory
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/cache');

      // Create cache directory if it doesn't exist
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // Initialize Hive with the cache directory
      await Hive.initFlutter(cacheDir.path);

      // Initialize the API cache box
      await _initBox(apiCacheBox);

      // Initialize SnipCacheManager
      _snipCacheManager = SnipCacheManager();

      // Perform initial maintenance
      await _performMaintenanceIfNeeded();

      _isInitialized = true;
      debugPrint('Cache service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing cache service: $e');
      // Try to recover by deleting and recreating the box
      try {
        await _recoverBox(apiCacheBox);
        _isInitialized = true;
        debugPrint('Cache service recovered successfully');
      } catch (e) {
        debugPrint('Failed to recover cache service: $e');
        // Don't rethrow, allow the app to continue without cache
      }
    }
  }

  static Future<void> _initBox(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    } catch (e) {
      debugPrint('Error opening box $boxName: $e');
      await _recoverBox(boxName);
    }
  }

  static Future<void> _recoverBox(String boxName) async {
    try {
      // Try to delete the box if it exists
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      await Hive.openBox(boxName);
    } catch (e) {
      debugPrint('Error recovering box $boxName: $e');
      // Don't rethrow, allow the app to continue without this box
    }
  }

  static Future<void> cacheData({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    if (!_isInitialized) await init();

    try {
      final box = Hive.box(apiCacheBox);
      final expiryTime = DateTime.now().add(duration ?? defaultCacheDuration);

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

  static Future<dynamic> getCachedData(String key) async {
    if (!_isInitialized) await init();

    try {
      final box = Hive.box(apiCacheBox);
      final cachedJson = box.get(key);

      if (cachedJson == null) return null;

      final cached = json.decode(cachedJson);
      final expiry = DateTime.parse(cached['expiry']);

      if (DateTime.now().isBefore(expiry)) {
        return cached['data'];
      } else {
        await box.delete(key);
        return null;
      }
    } catch (e) {
      debugPrint('Error retrieving cached data: $e');
      return null;
    }
  }

  static Future<void> clearCache(String key) async {
    if (!_isInitialized) await init();
    try {
      final box = Hive.box(apiCacheBox);
      await box.delete(key);
      debugPrint('Cleared cache for key: $key');
    } catch (e) {
      debugPrint('Error clearing cache for key $key: $e');
    }
  }

  static Future<void> clearAllCache() async {
    if (!_isInitialized) await init();
    try {
      final box = Hive.box(apiCacheBox);
      await box.clear();
      await _snipCacheManager?.emptyCache();
      debugPrint('Cleared all cache');
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

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

      for (var key in itemsToDelete) {
        await box.delete(key);
      }

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

  static Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized) await init();

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

  static Future<void> preloadMedia({
    List<String> videoUrls = const [],
    List<String> thumbnailUrls = const [],
    CachePriority priority = CachePriority.medium,
  }) async {
    if (_snipCacheManager == null) return;

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
    try {
      await _snipCacheManager?.emptyCache();
      debugPrint('Media cache cleaned');
    } catch (e) {
      debugPrint('Error cleaning media cache: $e');
    }
  }
}
