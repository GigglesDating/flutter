import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/utils/snip_cache_manager.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/services.dart';

class CacheService {
  static const String apiCacheBox = 'apiCache';
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static SnipCacheManager? _snipCacheManager;
  static bool _isInitialized = false;
  static Box? _apiCacheBox;
  static Future<void>? _initFuture;

  // Initialize Hive and open boxes
  static Future<void> init() async {
    if (_isInitialized) return;

    // If initialization is in progress, wait for it
    if (_initFuture != null) {
      await _initFuture;
      return;
    }

    _initFuture = _initializeCache();
    try {
      await _initFuture;
    } finally {
      _initFuture = null;
    }
  }

  static Future<void> _initializeCache() async {
    try {
      // Ensure background isolate messenger is initialized
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken != null) {
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        debugPrint(
            'BackgroundIsolateBinaryMessenger initialized in CacheService');
      } else {
        debugPrint('Warning: RootIsolateToken is null in CacheService');
      }

      // Get application documents directory with error handling
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      if (appDir.path.isEmpty) {
        throw Exception('Application documents directory path is empty');
      }

      debugPrint('Initializing Hive with path: ${appDir.path}');
      await Hive.initFlutter(appDir.path);

      // Open box and store reference
      _apiCacheBox = await Hive.openBox(apiCacheBox);
      _snipCacheManager = SnipCacheManager();
      _isInitialized = true;
      debugPrint('CacheService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing CacheService: $e');
      // Create a new box if there's an error with the existing one
      try {
        await Hive.deleteBoxFromDisk(apiCacheBox);
        _apiCacheBox = await Hive.openBox(apiCacheBox);
        _isInitialized = true;
        debugPrint('CacheService recovered after error');
      } catch (e) {
        debugPrint('Fatal error initializing CacheService: $e');
        // Don't rethrow, let the app continue with limited caching
        _isInitialized = false;
      }
    }
  }

  // Ensure cache is initialized before any operation
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // Cache data with expiration
  static Future<void> cacheData({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    await _ensureInitialized();
    if (_apiCacheBox == null) {
      debugPrint('CacheService box not available');
      return;
    }

    final expiryTime = DateTime.now().add(duration ?? defaultCacheDuration);
    final cacheData = {
      'data': data,
      'expiry': expiryTime.toIso8601String(),
    };

    await _apiCacheBox!.put(key, json.encode(cacheData));
  }

  // Get cached data if not expired
  static Future<dynamic> getCachedData(String key) async {
    await _ensureInitialized();
    if (_apiCacheBox == null) {
      debugPrint('CacheService box not available');
      return null;
    }

    final cachedJson = _apiCacheBox!.get(key);
    if (cachedJson == null) return null;

    try {
      final cached = json.decode(cachedJson);
      final expiry = DateTime.parse(cached['expiry']);

      if (DateTime.now().isBefore(expiry)) {
        return cached['data'];
      } else {
        // Clean up expired cache
        await _apiCacheBox!.delete(key);
        return null;
      }
    } catch (e) {
      debugPrint('Error reading cache: $e');
      return null;
    }
  }

  // Clear specific cache
  static Future<void> clearCache(String key) async {
    if (!_isInitialized || _apiCacheBox == null) {
      debugPrint('CacheService not initialized');
      return;
    }

    await _apiCacheBox!.delete(key);
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    if (!_isInitialized || _apiCacheBox == null) {
      debugPrint('CacheService not initialized');
      return;
    }

    await _apiCacheBox!.clear();
    await _snipCacheManager?.emptyCache();
  }

  // Clean expired cache entries
  static Future<void> cleanExpiredCache() async {
    if (!_isInitialized || _apiCacheBox == null) {
      debugPrint('CacheService not initialized');
      return;
    }

    final keys = _apiCacheBox!.keys.toList();

    for (var key in keys) {
      final cachedJson = _apiCacheBox!.get(key);
      if (cachedJson != null) {
        try {
          final cached = json.decode(cachedJson);
          final expiry = DateTime.parse(cached['expiry']);

          if (DateTime.now().isAfter(expiry)) {
            await _apiCacheBox!.delete(key);
          }
        } catch (e) {
          debugPrint('Error cleaning cache: $e');
          await _apiCacheBox!.delete(key);
        }
      }
    }

    // Clean SnipCacheManager if needed
    await _snipCacheManager?.cleanCacheIfNeeded();
  }

  // Get combined cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized || _apiCacheBox == null) {
      debugPrint('CacheService not initialized');
      return {};
    }

    int totalEntries = _apiCacheBox!.length;
    int expiredEntries = 0;
    int validEntries = 0;

    for (var key in _apiCacheBox!.keys) {
      final cachedJson = _apiCacheBox!.get(key);
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

    // Use Future.microtask for background operations
    Future.microtask(() async {
      try {
        // Process videos and thumbnails in parallel
        await Future.wait([
          _preloadVideos(videoUrls, priority),
          _preloadThumbnails(thumbnailUrls),
        ]);
      } catch (e) {
        debugPrint('Error preloading media: $e');
      }
    });
  }

  static Future<void> _preloadVideos(
      List<String> urls, CachePriority priority) async {
    for (var url in urls) {
      try {
        await _snipCacheManager?.preloadVideo(url);
      } catch (e) {
        debugPrint('Error preloading video $url: $e');
      }
    }
  }

  static Future<void> _preloadThumbnails(List<String> urls) async {
    for (var url in urls) {
      try {
        await _snipCacheManager?.preloadThumbnail(url);
      } catch (e) {
        debugPrint('Error preloading thumbnail $url: $e');
      }
    }
  }

  // Clean media cache
  static Future<void> cleanMediaCache() async {
    if (_snipCacheManager == null) return;

    // Use Future.microtask for background operations
    Future.microtask(() async {
      try {
        await _snipCacheManager?.emptyCache();
      } catch (e) {
        debugPrint('Error cleaning media cache: $e');
      }
    });
  }
}
