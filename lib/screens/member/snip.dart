// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:video_player/video_player.dart';
// import 'package:visibility_detector/visibility_detector.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../barrel.dart';
// import '../../models/snip_model.dart';
// import '../../services/video_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SnipTab extends StatefulWidget {
//   const SnipTab({super.key});

//   @override
//   State<SnipTab> createState() => _SnipTabState();
// }

// class _SnipTabState extends State<SnipTab> with TickerProviderStateMixin {
//   List<SnipModel> _snips = [];
//   bool _isLoading = true;
//   int _currentIndex = 0;
//   final Map<String, VideoPlayerController> _controllers = {};
//   bool _isPlaying = true;
//   bool _isMuted = false;
//   bool _isLiked = false;
//   bool _showHeart = false;
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _loadSnips();
//   }

//   Future<void> _loadSnips() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final uuid = prefs.getString('user_uuid');
//       if (uuid == null) throw Exception('No UUID found');

//       // Load snips in background
//       compute((uuid) async {
//         final response = await ThinkProvider().getSnips(uuid: uuid);
//         return SnipModel.fromApiResponse(response);
//       }, uuid)
//           .then((snips) {
//         if (!mounted) return;
//         setState(() {
//           _snips = snips;
//           _isLoading = false;
//         });
//         _initializeController(_currentIndex);
//       });
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _initializeController(int index) async {
//     if (index >= _snips.length) return;

//     final snip = _snips[index];
//     if (_controllers.containsKey(snip.snipId)) return;

//     final controller =
//         VideoPlayerController.networkUrl(Uri.parse(snip.video.source));
//     _controllers[snip.snipId] = controller;

//     await controller.initialize();
//     if (!mounted) return;

//     await controller.setLooping(true);
//     await controller.play();
//     setState(() {});
//   }

//   void _cleanupControllers() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     _controllers.clear();
//   }

//   void _onPageChanged(int index) async {
//     // Pause current video
//     final currentSnip = _snips[_currentIndex];
//     _controllers[currentSnip.snipId]?.pause();

//     setState(() => _currentIndex = index);

//     // Initialize next video if needed
//     await _initializeController(index);

//     // Play new video
//     final newSnip = _snips[index];
//     _controllers[newSnip.snipId]?.play();
//     setState(() => _isPlaying = true);

//     // Preload next video
//     if (index + 1 < _snips.length) {
//       _initializeController(index + 1);
//     }
//   }

//   void _togglePlayPause() {
//     if (_currentIndex >= _snips.length) return;

//     final snip = _snips[_currentIndex];
//     final controller = _controllers[snip.snipId];
//     if (controller == null) return;

//     setState(() {
//       _isPlaying = !_isPlaying;
//       _isPlaying ? controller.play() : controller.pause();
//     });
//   }

//   Future<void> _toggleVolume() async {
//     if (_currentIndex >= _snips.length) return;

//     final snip = _snips[_currentIndex];
//     final controller = _controllers[snip.snipId];
//     if (controller == null) return;

//     setState(() {
//       _isMuted = !_isMuted;
//       controller.setVolume(_isMuted ? 0.0 : 1.0);
//     });
//   }

//   void _onDoubleTap() {
//     HapticFeedback.lightImpact();
//     setState(() {
//       _isLiked = !_isLiked;
//       _showHeart = true;
//     });
//     _animationController.forward().then((_) {
//       _animationController.reverse().then((_) {
//         setState(() {
//           _showHeart = false;
//         });
//       });
//     });
//   }

//   void _showComments(SnipModel snip) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => CommentsSheet(
//         isDarkMode: isDarkMode,
//         contentId: snip.snipId,
//         contentType: 'snip',
//         commentIds: snip.commentIds,
//         authorProfile: snip.authorProfile,
//         screenHeight: MediaQuery.of(context).size.height,
//         screenWidth: MediaQuery.of(context).size.width,
//       ),
//     );
//   }

//   void _showShareSheet() {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       barrierColor: Colors.black.withOpacity(0.5),
//       builder: (context) => ShareSheet(
//         isDarkMode: isDarkMode,
//         post: {
//           'type': 'snip',
//           'url': _snips[_currentIndex].video.source,
//         },
//         screenWidth: MediaQuery.of(context).size.width,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_snips.isEmpty) {
//       return const Center(child: Text('No snips available'));
//     }

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             Text(
//               'Snip',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: isDarkMode ? Colors.white : Colors.black,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isDarkMode
//                     ? Colors.white.withOpacity(0.3)
//                     : Colors.black.withOpacity(0.1),
//               ),
//               child: SvgPicture.asset(
//                 'assets/icons/snip/snip_upload.svg',
//                 width: 24,
//                 height: 24,
//                 colorFilter: ColorFilter.mode(
//                   isDarkMode ? Colors.white : Colors.black.withOpacity(0.8),
//                   BlendMode.srcIn,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: PageView.builder(
//         scrollDirection: Axis.vertical,
//         itemCount: _snips.length,
//         onPageChanged: _onPageChanged,
//         itemBuilder: (context, index) {
//           final snip = _snips[index];
//           final controller = _controllers[snip.snipId];

//           if (controller == null || !controller.value.isInitialized) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return GestureDetector(
//             onTap: _togglePlayPause,
//             onDoubleTap: _onDoubleTap,
//             onLongPress: _toggleVolume,
//             child: Stack(
//               children: [
//                 Center(
//                   child: AspectRatio(
//                     aspectRatio: controller.value.aspectRatio,
//                     child: VideoPlayer(controller),
//                   ),
//                 ),
//                 if (_showHeart)
//                   Center(
//                     child: FadeTransition(
//                       opacity: _animationController,
//                       child: const Icon(
//                         Icons.favorite,
//                         color: Colors.red,
//                         size: 100,
//                       ),
//                     ),
//                   ),
//                 Positioned(
//                   right: MediaQuery.of(context).size.width * 0.02,
//                   bottom: MediaQuery.of(context).size.height * 0.15,
//                   child: ActionBar(
//                     isDarkMode: isDarkMode,
//                     isLiked: _isLiked,
//                     onLikeTap: _onDoubleTap,
//                     onCommentTap: () => _showComments(snip),
//                     onShareTap: _showShareSheet,
//                     orientation: ActionBarOrientation.vertical,
//                     backgroundColor: isDarkMode
//                         ? Colors.black.withOpacity(0.9)
//                         : Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _cleanupControllers();
//     _animationController.dispose();
//     super.dispose();
//   }
// }
