// import 'package:flutter/foundation.dart';
// import 'package:video_player/video_player.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'dart:async';
// import '../network/think.dart';

// class _VideoState {
//   VideoPlayerController? controller;
//   Timer? refreshTimer;
//   bool isInitialized = false;
//   String? currentUrl;
//   DateTime? urlExpiryTime;

//   void dispose() {
//     controller?.dispose();
//     refreshTimer?.cancel();
//   }
// }

// class AWSVideoService {
//   static final Map<String, _VideoState> _videoStates = {};
//   static final DefaultCacheManager _cacheManager = DefaultCacheManager();
//   static final ThinkProvider _thinkProvider = ThinkProvider();

//   static Future<VideoPlayerController> initializeVideo(String videoId) async {
//     // Get or create video state
//     var state = _videoStates[videoId] ?? _VideoState();
//     _videoStates[videoId] = state;

//     try {
//       // Check if URL needs refresh
//       if (state.urlExpiryTime == null ||
//           DateTime.now().isAfter(
//               state.urlExpiryTime!.subtract(const Duration(minutes: 5)))) {
//         // Get fresh signed URL from backend
//         final response = await _thinkProvider.getSnipVideoUrl(videoId);
//         if (response['status'] != 'success') {
//           throw Exception(response['message'] ?? 'Failed to get video URL');
//         }

//         final newUrl = response['data']['url'] as String;
//         final expiryTime = DateTime.now()
//             .add(const Duration(hours: 1)); // Assuming 1 hour validity

//         // Setup refresh timer
//         state.refreshTimer?.cancel();
//         state.refreshTimer = Timer(
//           const Duration(minutes: 55), // Refresh 5 minutes before expiry
//           () => _refreshVideo(videoId),
//         );

//         // Initialize new controller
//         final oldController = state.controller;
//         final position = oldController?.value.position;

//         // Cache video file
//         final file = await _cacheManager.getSingleFile(newUrl);
//         final controller = VideoPlayerController.file(file);
//         await controller.initialize();

//         // Restore position if needed
//         if (position != null) {
//           await controller.seekTo(position);
//         }

//         // Clean up old controller
//         await oldController?.dispose();

//         state.controller = controller;
//         state.currentUrl = newUrl;
//         state.urlExpiryTime = expiryTime;
//         state.isInitialized = true;

//         return controller;
//       }

//       return state.controller!;
//     } catch (e) {
//       debugPrint('Error initializing video $videoId: $e');
//       rethrow;
//     }
//   }

//   static Future<void> _refreshVideo(String videoId) async {
//     final state = _videoStates[videoId];
//     if (state == null) return;

//     try {
//       // Get fresh signed URL
//       final response = await _thinkProvider.getSnipVideoUrl(videoId);
//       if (response['status'] != 'success') {
//         throw Exception(response['message'] ?? 'Failed to get video URL');
//       }

//       final newUrl = response['data']['url'] as String;
//       final oldController = state.controller;
//       final position = await oldController?.position;

//       // Cache and initialize with new URL
//       final file = await _cacheManager.getSingleFile(newUrl);
//       final controller = VideoPlayerController.file(file);
//       await controller.initialize();

//       if (position != null) {
//         await controller.seekTo(position);
//       }

//       // Maintain play state
//       if (oldController?.value.isPlaying ?? false) {
//         await controller.play();
//       }

//       await oldController?.dispose();
//       state.controller = controller;
//       state.currentUrl = newUrl;
//       state.urlExpiryTime = DateTime.now().add(const Duration(hours: 1));

//       // Setup next refresh
//       state.refreshTimer?.cancel();
//       state.refreshTimer = Timer(
//         const Duration(minutes: 55),
//         () => _refreshVideo(videoId),
//       );
//     } catch (e) {
//       debugPrint('Error refreshing video $videoId: $e');
//     }
//   }

//   static void dispose(String videoId) {
//     _videoStates[videoId]?.dispose();
//     _videoStates.remove(videoId);
//   }

//   static void disposeAll() {
//     for (var state in _videoStates.values) {
//       state.dispose();
//     }
//     _videoStates.clear();
//   }
// }
