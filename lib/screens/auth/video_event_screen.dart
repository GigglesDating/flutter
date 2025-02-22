// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:giggles/constants/appColors.dart';
// import 'package:giggles/constants/appFonts.dart';
// import 'package:giggles/screens/auth/signUpPage.dart';
// import 'package:video_player/video_player.dart';

// class VideoEventScreen extends StatefulWidget {
//   bool? value;
//   String? videoUrl;

//   VideoEventScreen({super.key, this.value, this.videoUrl});

//   @override
//   State<VideoEventScreen> createState() => _VideoEventScreen();
// }

// class _VideoEventScreen extends State<VideoEventScreen> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;

//   // late Future<void> _initializeVideoPlayerFuture;
//   bool isPlaying = false;
//   bool _isFirstTimeCompleted = false;
//   bool _isButtonVisible = false;


//   void _enterFullPage() {
//     SystemChrome.setEnabledSystemUIMode(
//         SystemUiMode.immersiveSticky); // Hide system bars
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//     ]);
//   }

//   void _exitFullPage() {
//     SystemChrome.setEnabledSystemUIMode(
//         SystemUiMode.edgeToEdge); // Restore system bars
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//     // Navigator.of(context).pop();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _controller.dispose();
//     _exitFullPage();
//     super.dispose();
//   }

//   void _closeKeyboard() {
//     SystemChannels.textInput.invokeMethod('TextInput.hide');
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _enterFullPage();
//     print('12222222');
//     print(widget.videoUrl.toString());

//     _controller =
//         VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl.toString()))
//           // _initializeVideoPlayerFuture = _controller.initialize();
//           ..initialize().then((_) async {
//             setState(() {
//               _isInitialized = true;
//             });
//             _controller.play();
//             // Rebuild to show the video once initialized
//           });
//     _controller.addListener(() {
//       if (_controller.value.position == _controller.value.duration) {
//         // If the video is over, mark it as paused
//         setState(() {
//           if (!_isFirstTimeCompleted) {
//             // Show button only after the video completes the first time
//             setState(() {
//               _isButtonVisible = true;
//               _isFirstTimeCompleted = true;
//             });
//           }
//         });
//         setState(() {
//           isPlaying = false;
//         });
//       }
//     });

//     setState(() {});
//     // _controller.setLooping(true);
//     // _controller.play();
//   }

//   void _showSuccessDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Success'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(
//                 //     builder: (context) => userDashboard(),
//                 //   ),
//                 // );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to toggle play/pause
//   void _togglePlayPause() {
//     setState(() {
//       if (_controller.value.isPlaying) {
//         _controller.pause();
//         isPlaying = false;
//       } else {
//         _controller.play();
//         isPlaying = true;
//       }
//     });
//   }

//   // Function to go back and reset the orientation before popping the Page
//   Future<void> _goBack() async {
//     _exitFullPage();
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // await _goBack(); // Ensure orientation changes before navigating back
//         return widget.value ?? false;
//       },
//       child: Scaffold(
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           body: Stack(
//             children: [
//               Positioned.fill(
//                 child:
//                 _isInitialized
//                     ? FittedBox(
//                         fit: BoxFit.cover,
//                         child: SizedBox(
//                             width: _controller.value.size.width,
//                             height: _controller.value.size.height,
//                             child: VideoPlayer(_controller)),
//                       )
//                     :
//                 Center(
//                         child: Container(
//                             width: 48,
//                             height: 48,
//                             child: CircularProgressIndicator(
//                               color: AppColors.primary,
//                             ))),
//               ),
//               // Play/Pause button at the center
//               // Center(
//               //   child: GestureDetector(
//               //     onTap: _togglePlayPause,
//               //     child: _isPlaying
//               //         ? SizedBox.shrink() // Hide the button when video is playing
//               //         : Icon(
//               //       Icons.play_arrow,
//               //       color: Colors.white,
//               //       size: 80.0,
//               //     ),
//               //   ),
//               // ),
//               // Pause button on top when video is playing
//               // if (!_isPlaying)
//               //   Icon(
//               //     Icons.play_arrow,
//               //     color: Colors.white,
//               //     size: 80.0,
//               //   ),
//               if (!_controller.value.isPlaying)
//                 if(_isInitialized)
//                 GestureDetector(
//                   onTap: _togglePlayPause,
//                   child: Center(
//                     child: Icon(
//                       Icons.play_arrow,
//                       color: AppColors.white,
//                       size: 100.0,
//                     ),
//                   ),
//                 ),
//               // if (_isPlaying)
//               //   GestureDetector(
//               //     onTap: _togglePlayPause,
//               //     child: Center(
//               //       child: Icon(
//               //         Icons.pause,
//               //         color: Colors.white.withOpacity(0.4),
//               //         size: 80.0,
//               //       ),
//               //     ),
//               //   ),
//               if (widget.value ?? false)
//                 Positioned(
//                     top: 0,
//                     left: 0,
//                     child: IconButton(
//                         onPressed: () {
//                           SystemChrome.setEnabledSystemUIMode(
//                               SystemUiMode.edgeToEdge);
//                           SystemChrome.setPreferredOrientations([
//                             DeviceOrientation.portraitUp,
//                             DeviceOrientation.portraitDown,
//                           ]);
//                           Navigator.of(context).pop();
//                         },
//                         style: ButtonStyle(
//                             padding:
//                                 WidgetStatePropertyAll(EdgeInsets.all(24))),
//                         icon: Text(
//                           'Skip',
//                           style: AppFonts.titleBold(color: AppColors.primary),
//                         ))),
//               if (widget.value ?? false)
//                 Positioned(
//                     top: 0,
//                     right: 0,
//                     child: IconButton(
//                         onPressed: () {
//                           SystemChrome.setEnabledSystemUIMode(
//                               SystemUiMode.edgeToEdge);
//                           SystemChrome.setPreferredOrientations([
//                             DeviceOrientation.portraitUp,
//                             DeviceOrientation.portraitDown,
//                           ]);
//                           Navigator.of(context).pop();
//                         },
//                         style: ButtonStyle(
//                             padding:
//                                 WidgetStatePropertyAll(EdgeInsets.all(24))),
//                         icon: Icon(
//                           Icons.close,
//                           color: AppColors.primary,
//                         ))),
//               if (_isButtonVisible)
//                 if(_isInitialized)
//                 Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: TextButton(
//                         onPressed: () {
//                           if (widget.value ?? false) {
//                             Navigator.of(context).pop();
//                           } else {
//                             _exitFullPage();
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => SignUPPage(),
//                                 ));
//                           }
//                         },
//                         style: ButtonStyle(
//                             padding:
//                                 WidgetStatePropertyAll(EdgeInsets.all(24))),
//                         child: Text(
//                           'Continue',
//                           style: AppFonts.titleMedium(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: Theme.of(context).primaryColor),
//                         )))
//             ],
//           )),
//     );
//   }
// }
