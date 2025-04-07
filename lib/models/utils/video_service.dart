import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../models/snips_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'dart:math';

class VideoService {
  static final Map<String, VideoPlayerController> _controllers = {};
  static final Map<String, Future<void>> _initializingControllers = {};
  static final Map<String, VideoQuality> _currentQualities = {};
  static final Map<String, VideoAnalytics> _analytics = {};
  static final Map<String, Timer> _bufferTimers = {};
  static final Map<String, DateTime> _lastBufferTime = {};
  static final Map<String, int> _bufferCount = {};
  static const int _maxCachedControllers = 5;

  // Buffer management constants
  static const int _maxBufferCount = 3;
  static const Duration _bufferTimeThreshold = Duration(seconds: 30);

  // Pre-buffering queue
  static final List<String> _preBufferQueue = [];
  static const int _maxPreBufferedVideos = 2;
  static bool _isPreBuffering = false;

  // Preloaded controllers
  static final Map<String, VideoPlayerController> _preloadedControllers = {};
  static const int _maxPreloadedVideos = 2;

  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static final Map<String, int> _retryCount = {};

  // Track analytics for a video
  static void _updateAnalytics(
      String videoUrl, VideoAnalytics Function(VideoAnalytics) update) {
    final current = _analytics[videoUrl] ?? const VideoAnalytics();
    _analytics[videoUrl] = update(current);

    // FIXME(backend): Implement analytics API endpoint
    // Expected endpoint: POST /api/v1/snips/{snipId}/analytics
  }

  // Initialize video controller in background with quality
  static Future<VideoPlayerController?> initializeController(
    String videoUrl, {
    VideoQuality preferredQuality = VideoQuality.auto,
    Map<VideoQuality, String>? qualityUrls,
    List<String>? nextVideos,
  }) async {
    try {
      if (_controllers.containsKey(videoUrl)) {
        // Pre-buffer next videos if provided
        if (nextVideos != null && nextVideos.isNotEmpty) {
          _preBufferQueue.addAll(nextVideos);
          _startPreBuffering(qualityUrls);
        }
        return _controllers[videoUrl];
      }

      // Check if we have a preloaded controller
      if (_preloadedControllers.containsKey(videoUrl)) {
        final controller = _preloadedControllers.remove(videoUrl);
        _controllers[videoUrl] = controller!;
        return controller;
      }

      final startTime = DateTime.now();

      if (_initializingControllers.containsKey(videoUrl)) {
        await _initializingControllers[videoUrl];
        return _controllers[videoUrl];
      }

      if (_controllers.length >= _maxCachedControllers) {
        await _cleanupOldControllers();
      }

      // Initialize with retry logic
      int retryCount = 0;
      VideoPlayerController? controller;
      Exception? lastError;

      while (retryCount < _maxRetryAttempts) {
        try {
          // Create controller with direct URL first
          controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
          await controller.initialize();
          break;
        } catch (e) {
          lastError = e as Exception;
          controller?.dispose();

          // If direct URL fails, try downloading via cache manager
          try {
            final file = await DefaultCacheManager().getSingleFile(videoUrl);
            controller = VideoPlayerController.file(file);
            await controller.initialize();
            break;
          } catch (cacheError) {
            controller?.dispose();
            debugPrint('Cache attempt failed: $cacheError');

            retryCount++;
            if (retryCount < _maxRetryAttempts) {
              await Future.delayed(_retryDelay * pow(2, retryCount - 1));
            }
          }
        }
      }

      if (controller == null || !controller.value.isInitialized) {
        throw lastError ?? Exception('Failed to initialize video controller');
      }

      // Track initialization time
      final loadTime = DateTime.now().difference(startTime);
      _updateAnalytics(
        videoUrl,
        (current) => current.copyWith(
          averageLoadTime: loadTime,
        ),
      );

      // Setup controller
      controller.setLooping(true);
      await controller.setVolume(1.0);

      // Add to controllers map
      _controllers[videoUrl] = controller;
      _currentQualities[videoUrl] = preferredQuality;

      // Pre-buffer next videos if provided
      if (nextVideos != null && nextVideos.isNotEmpty) {
        _preBufferQueue.addAll(nextVideos);
        _startPreBuffering(qualityUrls);
      }

      return controller;
    } catch (e) {
      debugPrint('Error initializing video controller: $e');
      rethrow;
    }
  }

  // Handle initialization error with recovery attempts
  static Future<VideoPlayerController?> _handleInitializationError(
    String videoUrl,
    VideoQuality preferredQuality,
    Map<VideoQuality, String>? qualityUrls,
  ) async {
    try {
      // First recovery attempt: Try a lower quality
      if (qualityUrls != null && preferredQuality != VideoQuality.low) {
        debugPrint('Attempting recovery with lower quality...');
        return await initializeController(
          videoUrl,
          preferredQuality: VideoQuality.low,
          qualityUrls: qualityUrls,
        );
      }

      // Second recovery attempt: Clear cache and retry
      debugPrint('Attempting recovery by clearing cache...');
      await DefaultCacheManager().emptyCache();
      return await initializeController(
        videoUrl,
        preferredQuality: preferredQuality,
        qualityUrls: qualityUrls,
      );
    } catch (e) {
      debugPrint('Error recovery failed: $e');
      return null;
    }
  }

  // Pre-buffer videos in queue
  static Future<void> _startPreBuffering(
      Map<VideoQuality, String>? qualityUrls) async {
    if (_isPreBuffering || _preBufferQueue.isEmpty) return;

    _isPreBuffering = true;
    try {
      while (_preBufferQueue.isNotEmpty &&
          _controllers.length < _maxCachedControllers &&
          _controllers.length < _maxPreBufferedVideos) {
        final nextUrl = _preBufferQueue.removeAt(0);
        if (!_controllers.containsKey(nextUrl)) {
          debugPrint('Pre-buffering: $nextUrl');
          await initializeController(
            nextUrl,
            preferredQuality:
                VideoQuality.low, // Start with low quality for pre-buffering
            qualityUrls: qualityUrls,
          );
        }
      }
    } finally {
      _isPreBuffering = false;
    }
  }

  // Get optimal quality based on network conditions and buffer history
  static Future<VideoQuality> getOptimalQuality() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();

      // Simple quality selection based on network type
      switch (connectivity) {
        case ConnectivityResult.mobile:
          return VideoQuality.low;
        case ConnectivityResult.wifi:
          return VideoQuality.high;
        default:
          return VideoQuality.medium;
      }
    } catch (e) {
      debugPrint('Error checking network quality: $e');
      return VideoQuality.medium; // Safe default
    }
  }

  // Initialize new controller with quality selection
  static Future<void> _initializeNewController(
    String videoUrl, {
    VideoQuality preferredQuality = VideoQuality.auto,
    Map<VideoQuality, String>? qualityUrls,
  }) async {
    try {
      final quality = preferredQuality == VideoQuality.auto
          ? await getOptimalQuality()
          : preferredQuality;

      // Always use URL parameter approach for now
      final uri = Uri.parse(videoUrl);
      final newUri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'quality': quality.toString().split('.').last.toLowerCase(),
      });
      final finalUrl = newUri.toString();

      final file = await DefaultCacheManager().getSingleFile(finalUrl);
      final controller = VideoPlayerController.file(file);
      await controller.initialize();

      // Enhanced playback monitoring
      controller.addListener(() {
        // Video completed
        if (!controller.value.isPlaying &&
            controller.value.position == controller.value.duration) {
          _updateAnalytics(
              videoUrl,
              (current) => current.copyWith(
                    completeViewCount: current.completeViewCount + 1,
                  ));
        }

        // Buffer state changed
        if (controller.value.isBuffering) {
          _handleBuffering(videoUrl);
          _updateAnalytics(
              videoUrl,
              (current) => current.copyWith(
                    bufferEvents: current.bufferEvents + 1,
                  ));
        }

        // Track playback position for analytics
        final position = controller.value.position.inSeconds;
        if (position % 10 == 0) {
          // Every 10 seconds
          _updateAnalytics(videoUrl, (current) {
            final points = Map<int, int>.from(current.dropOffPoints);
            points.update(position, (count) => count + 1, ifAbsent: () => 1);
            return current.copyWith(dropOffPoints: points);
          });
        }
      });

      controller.setLooping(true);
      await controller.setVolume(1.0);

      _controllers[videoUrl] = controller;
      _currentQualities[videoUrl] = quality;

      // Start monitoring network quality if auto quality is enabled
      if (preferredQuality == VideoQuality.auto) {
        _startNetworkMonitoring(videoUrl, qualityUrls);
      }
    } catch (e) {
      debugPrint('Error in _initializeNewController: $e');
      rethrow;
    }
  }

  // Switch video quality
  static Future<void> switchQuality(
    String videoUrl,
    VideoQuality newQuality,
    Map<VideoQuality, String>? qualityUrls,
  ) async {
    try {
      final controller = _controllers[videoUrl];
      if (controller == null) return;

      final currentPosition = controller.value.position;
      final wasPlaying = controller.value.isPlaying;

      // Create URL with quality parameter
      final uri = Uri.parse(videoUrl);
      final newUri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'quality': newQuality.toString().split('.').last.toLowerCase(),
      });
      final newUrl = newUri.toString();

      // Initialize new controller with new quality
      final file = await DefaultCacheManager().getSingleFile(newUrl);
      final newController = VideoPlayerController.file(file);

      await newController.initialize();
      await newController.seekTo(currentPosition);
      newController.setLooping(true);
      await newController.setVolume(controller.value.volume);

      // Replace old controller
      await controller.dispose();
      _controllers[videoUrl] = newController;
      _currentQualities[videoUrl] = newQuality;

      if (wasPlaying) {
        await newController.play();
      }

      // Track quality switch
      _updateAnalytics(
          videoUrl,
          (current) => current.copyWith(
                qualitySwitches: current.qualitySwitches + 1,
              ));
    } catch (e) {
      debugPrint('Error switching quality: $e');
      _updateAnalytics(
          videoUrl,
          (current) => current.copyWith(
                errorCount: current.errorCount + 1,
              ));
    }
  }

  // Monitor network quality and switch automatically
  static void _startNetworkMonitoring(
    String videoUrl,
    Map<VideoQuality, String>? qualityUrls,
  ) {
    Connectivity().onConnectivityChanged.listen(
      (result) async {
        if (!_controllers.containsKey(videoUrl)) return;

        final newQuality = await getOptimalQuality();
        final currentQuality = _currentQualities[videoUrl];

        if (newQuality != currentQuality) {
          await switchQuality(videoUrl, newQuality, qualityUrls);
        }
      },
    );
  }

  // Clean up least recently used controllers
  static Future<void> _cleanupOldControllers() async {
    if (_controllers.isEmpty) return;

    try {
      final oldestUrl = _controllers.keys.first;
      await disposeController(oldestUrl);
    } catch (e) {
      debugPrint('Error cleaning up controllers: $e');
    }
  }

  // Dispose single controller
  static Future<void> disposeController(String videoUrl) async {
    try {
      final controller = _controllers[videoUrl];
      if (controller != null) {
        await controller.dispose();
        _controllers.remove(videoUrl);
      }
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
  }

  // Dispose all controllers
  static Future<void> disposeAllControllers() async {
    try {
      for (final controller in _controllers.values) {
        await controller.dispose();
      }
      _controllers.clear();
      _initializingControllers.clear();
    } catch (e) {
      debugPrint('Error disposing all controllers: $e');
    }
  }

  // Play video
  static Future<void> play(String videoUrl) async {
    try {
      final controller = _controllers[videoUrl];
      if (controller != null && controller.value.isInitialized) {
        await controller.play();

        // Track view
        _updateAnalytics(
            videoUrl,
            (current) => current.copyWith(
                  viewCount: current.viewCount + 1,
                ));
      }
    } catch (e) {
      debugPrint('Error playing video: $e');
    }
  }

  // Pause video
  static Future<void> pause(String videoUrl) async {
    try {
      final controller = _controllers[videoUrl];
      if (controller != null && controller.value.isInitialized) {
        await controller.pause();
      }
    } catch (e) {
      debugPrint('Error pausing video: $e');
    }
  }

  // Toggle play/pause
  static Future<void> togglePlay(String videoUrl) async {
    try {
      final controller = _controllers[videoUrl];
      if (controller != null && controller.value.isInitialized) {
        if (controller.value.isPlaying) {
          await controller.pause();
        } else {
          await controller.play();
        }
      }
    } catch (e) {
      debugPrint('Error toggling video: $e');
    }
  }

  // Toggle mute
  static Future<void> toggleMute(String videoUrl) async {
    try {
      final controller = _controllers[videoUrl];
      if (controller != null && controller.value.isInitialized) {
        final newVolume = controller.value.volume > 0 ? 0.0 : 1.0;
        await controller.setVolume(newVolume);
      }
    } catch (e) {
      debugPrint('Error toggling mute: $e');
    }
  }

  // Check if video is ready
  static bool isVideoReady(String videoUrl) {
    final controller = _controllers[videoUrl];
    return controller != null && controller.value.isInitialized;
  }

  // Get controller if exists
  static VideoPlayerController? getController(String videoUrl) {
    return _controllers[videoUrl];
  }

  // Track interaction
  static void trackInteraction(String videoUrl, String action) {
    try {
      final controller = _controllers[videoUrl];
      if (controller != null && controller.value.isInitialized) {
        final position = controller.value.position.inSeconds;

        _updateAnalytics(videoUrl, (current) {
          final points =
              Map<int, Map<String, int>>.from(current.interactionPoints);
          points.putIfAbsent(position, () => {}).update(
                action,
                (count) => count + 1,
                ifAbsent: () => 1,
              );

          return current.copyWith(interactionPoints: points);
        });
      }
    } catch (e) {
      debugPrint('Error tracking interaction: $e');
    }
  }

  // Track drop-off
  static void trackDropOff(String videoUrl) {
    try {
      final controller = _controllers[videoUrl];
      if (controller != null && controller.value.isInitialized) {
        final position = controller.value.position.inSeconds;

        _updateAnalytics(videoUrl, (current) {
          final points = Map<int, int>.from(current.dropOffPoints);
          points.update(
            position,
            (count) => count + 1,
            ifAbsent: () => 1,
          );

          return current.copyWith(dropOffPoints: points);
        });
      }
    } catch (e) {
      debugPrint('Error tracking drop-off: $e');
    }
  }

  // Get current analytics
  static VideoAnalytics? getAnalytics(String videoUrl) {
    return _analytics[videoUrl];
  }

  // Enhanced buffer management
  static void _handleBuffering(String videoUrl) {
    final now = DateTime.now();
    final lastBuffer = _lastBufferTime[videoUrl];

    // Reset buffer count if outside time threshold
    if (lastBuffer == null ||
        now.difference(lastBuffer) > _bufferTimeThreshold) {
      _bufferCount[videoUrl] = 1;
    } else {
      _bufferCount[videoUrl] = (_bufferCount[videoUrl] ?? 0) + 1;
    }

    _lastBufferTime[videoUrl] = now;

    // Cancel existing buffer timer
    _bufferTimers[videoUrl]?.cancel();

    // Start new buffer timer
    _bufferTimers[videoUrl] = Timer(const Duration(seconds: 5), () {
      _handleBufferTimeout(videoUrl);
    });

    // Check if we need to decrease quality
    if ((_bufferCount[videoUrl] ?? 0) >= _maxBufferCount) {
      _handleExcessiveBuffering(videoUrl);
    }
  }

  // Handle buffer timeout
  static void _handleBufferTimeout(String videoUrl) {
    final controller = _controllers[videoUrl];
    if (controller == null) return;

    // If still buffering after timeout, attempt recovery
    if (controller.value.isBuffering) {
      _handleExcessiveBuffering(videoUrl);
    }
  }

  // Handle excessive buffering
  static void _handleExcessiveBuffering(String videoUrl) async {
    final currentQuality = _currentQualities[videoUrl];
    if (currentQuality == null) return;

    // Don't decrease if already at lowest
    if (currentQuality == VideoQuality.low) return;

    // Decrease quality
    final newQuality = VideoQuality.values[currentQuality.index - 1];
    debugPrint('Decreasing quality due to buffering: $newQuality');

    final controller = _controllers[videoUrl];
    if (controller == null) return;

    // Store current position
    final position = controller.value.position;

    // Switch quality
    await switchQuality(
      videoUrl,
      newQuality,
      null, // We're not using quality URLs yet
    );

    // Seek to previous position
    final newController = _controllers[videoUrl];
    if (newController != null) {
      await newController.seekTo(position);
    }
  }

  static Future<void> preloadVideos(List<String> videoUrls) async {
    // Remove old preloaded controllers
    for (final controller in _preloadedControllers.values) {
      controller.dispose();
    }
    _preloadedControllers.clear();

    // Preload new videos with retry mechanism
    for (int i = 0; i < videoUrls.length && i < _maxPreloadedVideos; i++) {
      final url = videoUrls[i];
      if (!_controllers.containsKey(url)) {
        await _preloadVideoWithRetry(url);
      }
    }
  }

  static Future<void> _preloadVideoWithRetry(String url) async {
    _retryCount[url] = 0;
    bool success = false;

    while (!success && (_retryCount[url] ?? 0) < _maxRetryAttempts) {
      try {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url));
        await controller.initialize();
        _preloadedControllers[url] = controller;
        success = true;
        _retryCount.remove(url); // Clear retry count on success
      } catch (e) {
        _retryCount[url] = (_retryCount[url] ?? 0) + 1;
        debugPrint('Error preloading video (attempt ${_retryCount[url]}): $e');

        if (_retryCount[url]! < _maxRetryAttempts) {
          // Exponential backoff
          final delay = _retryDelay * pow(2, _retryCount[url]! - 1);
          await Future.delayed(delay);
        }
      }
    }

    if (!success) {
      debugPrint(
          'Failed to preload video after $_maxRetryAttempts attempts: $url');
      _retryCount.remove(url);
    }
  }

  static void clearPreloadedVideos() {
    for (final controller in _preloadedControllers.values) {
      controller.dispose();
    }
    _preloadedControllers.clear();
    _retryCount.clear(); // Clear retry counts
  }

  // Adaptive bitrate streaming support
  static Future<String> getOptimalQualityUrl(
      String baseUrl, List<String> qualities, double bandwidth) async {
    // Sort qualities from lowest to highest
    final sortedQualities = List<String>.from(qualities)
      ..sort((a, b) {
        final aRes = int.tryParse(a.replaceAll('p', '')) ?? 0;
        final bRes = int.tryParse(b.replaceAll('p', '')) ?? 0;
        return aRes.compareTo(bRes);
      });

    // Calculate optimal quality based on bandwidth
    String selectedQuality = sortedQualities.first; // Default to lowest quality
    for (final quality in sortedQualities) {
      final resolution = int.tryParse(quality.replaceAll('p', '')) ?? 0;
      final requiredBandwidth =
          resolution * 2000; // Rough estimate: resolution * bitrate factor
      if (bandwidth >= requiredBandwidth) {
        selectedQuality = quality;
      } else {
        break;
      }
    }

    return '$baseUrl/$selectedQuality.m3u8';
  }
}
