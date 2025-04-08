import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';

// Import the models
import '../video_quality.dart';

class VideoService {
  // Static maps for controller management
  static final Map<String, VideoPlayerController> _controllers = {};
  static final Map<String, Completer<void>> _initializationCompleters = {};
  static final Map<String, bool> _isInitializing = {};
  static final Map<String, VideoQuality> _currentQualities = {};
  static final Map<String, Map<VideoQuality, String>> _qualityUrls = {};
  static final Map<String, DateTime> _lastQualityCheck = {};
  static const Duration _qualityCheckInterval = Duration(seconds: 10);

  // Initialize video controller with quality management
  static Future<VideoPlayerController?> initializeController(
    String videoUrl, {
    VideoQuality preferredQuality = VideoQuality.auto,
    Map<VideoQuality, String>? qualityUrls,
  }) async {
    try {
      debugPrint('Initializing video controller for URL: $videoUrl');
      debugPrint('Preferred quality: $preferredQuality');
      if (qualityUrls != null) {
        debugPrint('Available qualities: ${qualityUrls.keys.join(", ")}');
      }

      // Check if controller already exists
      if (_controllers.containsKey(videoUrl)) {
        debugPrint('Returning existing controller');
        return _controllers[videoUrl];
      }

      // If already initializing, wait for completion
      if (_isInitializing[videoUrl] == true) {
        debugPrint('Waiting for existing initialization');
        await _initializationCompleters[videoUrl]?.future;
        return _controllers[videoUrl];
      }

      _isInitializing[videoUrl] = true;
      _initializationCompleters[videoUrl] = Completer<void>();

      // Store quality URLs for later use
      if (qualityUrls != null) {
        _qualityUrls[videoUrl] = qualityUrls;
      }

      // Select initial quality
      final initialQuality =
          await _selectAppropriateQuality(videoUrl, preferredQuality);
      final selectedUrl = qualityUrls?[initialQuality] ?? videoUrl;
      debugPrint('Selected quality: $initialQuality');
      debugPrint('Selected URL: $selectedUrl');

      // Create and initialize controller
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(selectedUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      try {
        await controller.initialize();
        debugPrint('Controller initialized successfully');

        // Configure playback
        await controller.setLooping(true);
        await controller.setVolume(1.0);

        // Store controller and quality
        _controllers[videoUrl] = controller;
        _currentQualities[videoUrl] = initialQuality;

        // Add quality check listener
        controller.addListener(() => _checkQualitySwitch(videoUrl));

        _initializationCompleters[videoUrl]?.complete();
        return controller;
      } catch (e) {
        debugPrint('Error during controller initialization: $e');
        controller.dispose();
        _cleanupController(videoUrl);
        rethrow;
      }
    } catch (e) {
      debugPrint('Error in initializeController: $e');
      _cleanupController(videoUrl);
      return null;
    } finally {
      _isInitializing[videoUrl] = false;
    }
  }

  static Future<VideoQuality> _selectAppropriateQuality(
    String videoUrl,
    VideoQuality preferredQuality,
  ) async {
    if (preferredQuality != VideoQuality.auto) {
      return preferredQuality;
    }

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final qualityUrls = _qualityUrls[videoUrl];

      if (qualityUrls == null) {
        return VideoQuality.auto;
      }

      switch (connectivity) {
        case ConnectivityResult.wifi:
          return qualityUrls.containsKey(VideoQuality.high)
              ? VideoQuality.high
              : VideoQuality.medium;
        case ConnectivityResult.mobile:
          return qualityUrls.containsKey(VideoQuality.medium)
              ? VideoQuality.medium
              : VideoQuality.low;
        default:
          return qualityUrls.containsKey(VideoQuality.low)
              ? VideoQuality.low
              : VideoQuality.auto;
      }
    } catch (e) {
      debugPrint('Error selecting quality: $e');
      return VideoQuality.auto;
    }
  }

  static void _checkQualitySwitch(String videoUrl) async {
    final lastCheck = _lastQualityCheck[videoUrl];
    if (lastCheck != null &&
        DateTime.now().difference(lastCheck) < _qualityCheckInterval) {
      return;
    }

    _lastQualityCheck[videoUrl] = DateTime.now();
    final controller = _controllers[videoUrl];
    if (controller == null) return;

    try {
      if (controller.value.isBuffering) {
        final currentQuality = _currentQualities[videoUrl];
        final qualityUrls = _qualityUrls[videoUrl];

        if (currentQuality == null || qualityUrls == null) return;

        // Switch to lower quality if buffering
        final lowerQuality = _getLowerQuality(currentQuality);
        if (lowerQuality != null && qualityUrls.containsKey(lowerQuality)) {
          await switchQuality(videoUrl, lowerQuality);
        }
      }
    } catch (e) {
      debugPrint('Error in quality check: $e');
    }
  }

  static VideoQuality? _getLowerQuality(VideoQuality current) {
    const qualities = VideoQuality.values;
    final currentIndex = qualities.indexOf(current);
    if (currentIndex > 1) {
      // Skip 'auto'
      return qualities[currentIndex - 1];
    }
    return null;
  }

  static Future<void> switchQuality(
      String videoUrl, VideoQuality newQuality) async {
    final controller = _controllers[videoUrl];
    final qualityUrls = _qualityUrls[videoUrl];

    if (controller == null || qualityUrls == null) return;

    try {
      final newUrl = qualityUrls[newQuality];
      if (newUrl == null) return;

      final position = controller.value.position;

      // Create new controller
      final newController = VideoPlayerController.networkUrl(
        Uri.parse(newUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await newController.initialize();
      await newController.seekTo(position);
      await newController.setLooping(true);
      await newController.setVolume(controller.value.volume);

      if (controller.value.isPlaying) {
        await newController.play();
      }

      // Switch controllers
      final oldController = _controllers[videoUrl];
      _controllers[videoUrl] = newController;
      _currentQualities[videoUrl] = newQuality;

      oldController?.dispose();

      debugPrint('Switched to quality: $newQuality');
    } catch (e) {
      debugPrint('Error switching quality: $e');
    }
  }

  static void _cleanupController(String videoUrl) {
    _controllers.remove(videoUrl);
    _initializationCompleters.remove(videoUrl);
    _isInitializing.remove(videoUrl);
    _currentQualities.remove(videoUrl);
    _qualityUrls.remove(videoUrl);
    _lastQualityCheck.remove(videoUrl);
  }

  static VideoPlayerController? getController(String videoUrl) {
    return _controllers[videoUrl];
  }

  static Future<void> disposeController(String videoUrl) async {
    final controller = _controllers[videoUrl];
    if (controller != null) {
      await controller.dispose();
      _cleanupController(videoUrl);
    }
  }

  static Future<void> disposeAllControllers() async {
    final controllers = List<VideoPlayerController>.from(_controllers.values);
    for (var controller in controllers) {
      await controller.dispose();
    }
    _controllers.clear();
    _initializationCompleters.clear();
    _isInitializing.clear();
    _currentQualities.clear();
    _qualityUrls.clear();
    _lastQualityCheck.clear();
  }
}
