// import 'package:flutter/material.dart';
// import '../models/snip_model.dart';
// import 'package:video_player/video_player.dart';

// class ReelCard extends StatefulWidget {
//   final SnipModel snip;
//   final bool isDarkMode;
//   final int index;
//   final VoidCallback? onNext;
//   final VoidCallback? onPrevious;

//   const ReelCard({
//     required this.snip,
//     required this.isDarkMode,
//     required this.index,
//     this.onNext,
//     this.onPrevious,
//     super.key,
//   });

//   @override
//   State<ReelCard> createState() => _ReelCardState();
// }

// class _ReelCardState extends State<ReelCard> {
//   late VideoPlayerController _controller;
//   bool _isPlaying = true;
//   bool _isInitialized = false;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       _controller =
//           VideoPlayerController.networkUrl(Uri.parse(widget.snip.video.source));
//       await _controller.initialize();
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//         _controller.play();
//         _controller.setLooping(true);
//       }
//     } catch (e) {
//       debugPrint('Error initializing video: $e');
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//         });
//       }
//     }
//   }

//   void _togglePlay() {
//     if (_controller.value.isPlaying) {
//       _controller.pause();
//     } else {
//       _controller.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_hasError) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               color: widget.isDarkMode ? Colors.white : Colors.black,
//               size: 48,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Failed to load video',
//               style: TextStyle(
//                 color: widget.isDarkMode ? Colors.white : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (!_isInitialized) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     return GestureDetector(
//       onTap: _togglePlay,
//       onHorizontalDragEnd: (details) {
//         final velocity = details.primaryVelocity ?? 0;
//         if (velocity > 0 && widget.onPrevious != null) {
//           widget.onPrevious!();
//         } else if (velocity < 0 && widget.onNext != null) {
//           widget.onNext!();
//         }
//       },
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           VideoPlayer(_controller),
//           if (!_isPlaying)
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withValues(alpha: 128),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.play_arrow,
//                   color: Colors.white,
//                   size: 48,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
