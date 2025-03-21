import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  static const Duration _cacheDuration = Duration(days: 7);
  static const int _maxCacheSize = 200 * 1024 * 1024; // 200MB

  final _imageCache = <String, bool>{};
  final _preloadQueue = <String>[];
  bool _isPreloading = false;

  static final _customCacheManager = CacheManager(
    Config(
      'giggles_images_cache',
      stalePeriod: _cacheDuration,
      maxNrOfCacheObjects: 1000,
      repo: JsonCacheInfoRepository(databaseName: 'giggles_images_cache'),
      fileService: HttpFileService(),
    ),
  );

  Future<void> preloadImage(String url, {String? cacheKey}) async {
    if (url.isEmpty) return;

    final key = cacheKey ?? url;
    if (_imageCache[key] == true) return;

    _preloadQueue.add(url);
    _imageCache[key] = false;

    if (!_isPreloading) {
      _processPreloadQueue();
    }
  }

  Future<void> _processPreloadQueue() async {
    if (_preloadQueue.isEmpty || _isPreloading) return;

    _isPreloading = true;

    while (_preloadQueue.isNotEmpty) {
      final url = _preloadQueue.removeAt(0);
      try {
        await _customCacheManager.downloadFile(url);
        _imageCache[url] = true;
      } catch (e) {
        debugPrint('Error preloading image $url: $e');
      }
    }

    _isPreloading = false;
  }

  Future<void> preloadImages(List<String> urls) async {
    for (final url in urls) {
      await preloadImage(url);
    }
  }

  Widget buildImage({
    required String imageUrl,
    required double width,
    required double height,
    String? cacheKey,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    Widget Function(BuildContext, String)? placeholderWidget,
  }) {
    if (imageUrl.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.error),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _customCacheManager,
      width: width,
      height: height,
      fit: fit,
      cacheKey: cacheKey,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholderFadeInDuration: const Duration(milliseconds: 150),
      errorWidget: errorWidget ??
          (context, url, error) => Icon(
                Icons.error,
                size: width * 0.5,
                color: Colors.grey,
              ),
      placeholder: placeholderWidget ??
          (context, url) => Container(
                color: Colors.grey[300],
                child: Center(
                  child: SizedBox(
                    width: width * 0.3,
                    height: width * 0.3,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
    );
  }

  Future<void> clearCache() async {
    await _customCacheManager.emptyCache();
    _imageCache.clear();
    _preloadQueue.clear();
    _isPreloading = false;
  }
}
