import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../models/snip_model.dart';

class VideoService {
  static final Map<String, VideoPlayerController> _controllers = {};
  static final Map<String, Completer<void>> _initializationCompleters = {};
  static final Map<String, bool> _isInitializing = {};

  static Future<VideoPlayerController?> initializeController(
      SnipModel snip) async {
    if (_controllers.containsKey(snip.snipId)) {
      return _controllers[snip.snipId];
    }

    // If already initializing, wait for completion
    if (_isInitializing[snip.snipId] == true) {
      await _initializationCompleters[snip.snipId]?.future;
      return _controllers[snip.snipId];
    }

    _isInitializing[snip.snipId] = true;
    _initializationCompleters[snip.snipId] ??= Completer<void>();

    try {
      // Create controller in isolate
      final controller = await compute(_createController, snip.video.source);
      _controllers[snip.snipId] = controller;

      // Initialize in background
      unawaited(_initializeInBackground(snip.snipId, controller));

      return controller;
    } catch (e) {
      debugPrint('Error initializing video controller: $e');
      _cleanupController(snip.snipId);
      return null;
    }
  }

  static Future<void> _initializeInBackground(
      String snipId, VideoPlayerController controller) async {
    try {
      await controller.initialize();
      await controller.setLooping(true);
      _initializationCompleters[snipId]?.complete();
    } catch (e) {
      debugPrint('Error in background initialization: $e');
      _initializationCompleters[snipId]?.completeError(e);
      _cleanupController(snipId);
    } finally {
      _isInitializing[snipId] = false;
    }
  }

  static void _cleanupController(String snipId) {
    _controllers.remove(snipId);
    _initializationCompleters.remove(snipId);
    _isInitializing.remove(snipId);
  }

  static Future<VideoPlayerController> _createController(
      String videoUrl) async {
    return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
  }

  static VideoPlayerController? getController(String snipId) {
    return _controllers[snipId];
  }

  static Future<void> disposeController(String snipId) async {
    final controller = _controllers[snipId];
    if (controller != null) {
      await controller.dispose();
      _cleanupController(snipId);
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
  }

  static Future<void> preloadVideos(
      List<SnipModel> snips, int currentIndex, int preloadLimit) async {
    final start = (currentIndex - preloadLimit).clamp(0, snips.length);
    final end = (currentIndex + preloadLimit).clamp(0, snips.length);

    // Dispose controllers outside preload range in background
    unawaited(_disposeOutOfRangeVideos(snips, start, end));

    // Initialize controllers within preload range
    final futures = <Future>[];
    for (var i = start; i <= end; i++) {
      if (i >= 0 && i < snips.length) {
        futures.add(initializeController(snips[i]));
      }
    }
    await Future.wait(futures);
  }

  static Future<void> _disposeOutOfRangeVideos(
      List<SnipModel> snips, int start, int end) async {
    for (var i = 0; i < snips.length; i++) {
      if (i < start || i > end) {
        await disposeController(snips[i].snipId);
      }
    }
  }
}
