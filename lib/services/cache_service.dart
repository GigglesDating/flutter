import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import '../models/utils/snip_cache_manager.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

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
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDir.path);

      if (!Hive.isBoxOpen(apiCacheBox)) {
        await Hive.openBox(apiCacheBox);
      }

      _snipCacheManager = SnipCacheManager();
      await _performMaintenanceIfNeeded();
      _isInitialized = true;
    } catch (e) {
      try {
        await Hive.deleteBoxFromDisk(apiCacheBox);
        await Hive.openBox(apiCacheBox);
        _isInitialized = true;
      } catch (e) {
        rethrow;
      }
    }
  }

  static Future<void> cacheData({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    if (!_isInitialized) await init();

    final box = Hive.box(apiCacheBox);
    final expiryTime = DateTime.now().add(duration ?? defaultCacheDuration);

    final dataSize = utf8.encode(json.encode(data)).length;
    if (dataSize > maxItemSize) return;

    final cacheData = {
      'data': data,
      'expiry': expiryTime.toIso8601String(),
      'size': dataSize,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await box.put(key, json.encode(cacheData));
    } catch (e) {
      // Silently fail on cache write error
    }

    await _performMaintenanceIfNeeded();
  }

  static Future<dynamic> getCachedData(String key) async {
    if (!_isInitialized) await init();

    final box = Hive.box(apiCacheBox);
    final cachedJson = box.get(key);

    if (cachedJson == null) return null;

    try {
      final cached = json.decode(cachedJson);
      final expiry = DateTime.parse(cached['expiry']);

      if (DateTime.now().isBefore(expiry)) {
        return cached['data'];
      } else {
        await box.delete(key);
        return null;
      }
    } catch (e) {
      await box.delete(key);
      return null;
    }
  }

  static Future<void> clearCache(String key) async {
    if (!_isInitialized) await init();
    final box = Hive.box(apiCacheBox);
    await box.delete(key);
  }

  static Future<void> clearAllCache() async {
    if (!_isInitialized) await init();
    final box = Hive.box(apiCacheBox);
    await box.clear();
    await _snipCacheManager?.emptyCache();
  }

  static Future<void> _performMaintenanceIfNeeded() async {
    if (DateTime.now().difference(_lastCleanup) < cleanupInterval) {
      return;
    }

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
  }

  static Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized) await init();

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
  }

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

  static Future<void> cleanMediaCache() async {
    await _snipCacheManager?.emptyCache();
  }
}
