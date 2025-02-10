// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:video_player/video_player.dart';

// class SnipTab extends StatefulWidget {
//   const SnipTab({Key? key}) : super(key: key);

//   @override
//   State<SnipTab> createState() => _SnipTab();
// }

// class _SnipTab extends State<SnipTab> with SingleTickerProviderStateMixin {
//   late VideoPlayerController _controller;
//   bool isPlaying = false;
//   CameraController? _cameraController;
//   bool _isCameraInitialized = false;
//   TextEditingController commentController = TextEditingController();
//   FocusNode commentFocusNode = FocusNode();
//   final GlobalKey _buttonKey = GlobalKey();
//   bool _isMuted = false;
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   bool _isLiked = false;

//   void toggleVolume() {
//     setState(() {
//       _isMuted = !_isMuted;
//       _controller.setVolume(
//           _isMuted ? 0.0 : 1.0); // Set volume to 0.0 if muted, 1.0 if unmuted
//       _controller.play();
//     });
//   }

//   void pauser() {
//     setState(() {
//       _controller.pause();
//       isPlaying = false;
//       _isMuted = !_isMuted;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
//       statusBarColor: Colors.transparent,
//       // Make it transparent or choose any color
//       statusBarIconBrightness: Brightness.light,
//       // Set icons to white
//       statusBarBrightness: Brightness.light, // For iOS
//     ));
//     _controller = VideoPlayerController.asset('assets/video/snip_reel.mp4');
//     // _initializeVideoPlayerFuture = _controller.initialize();

//     _controller.initialize().then((_) {
//       // Start playing the video automatically
//       _controller.play();
//       setState(() {}); // Rebuild to show the video once initialized
//     });
//     _controller.addListener(() {
//       if (_controller.value.position >= _controller.value.duration) {
//         _controller.seekTo(Duration.zero); // Restart the video
//         _controller.play(); // Play it again
//       }
//     });
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 300),
//     );

//     _animation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     );
//   }

//   void onDoubleTap() {
//     if (!_isLiked) {
//       setState(() {
//         _isLiked = true;
//       });
//       _animationController
//           .forward()
//           .then((_) => _animationController.reverse());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
//       statusBarColor: Colors.transparent,
//       // Make it transparent or choose any color
//       statusBarIconBrightness: Brightness.light,
//       // Set icons to white
//       statusBarBrightness: Brightness.light, // For iOS
//     ));
//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView.builder(
//             itemCount: 6,
//             scrollDirection: Axis.vertical,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: toggleVolume,
//                 onDoubleTap: onDoubleTap,
//                 onLongPress: pauser,
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                       child: FittedBox(
//                         fit: BoxFit.cover,
//                         child: SizedBox(
//                           width: _controller.value.size.width,
//                           height: _controller.value.size.height,
//                           child: VideoPlayer(_controller),
//                         ),
//                       ),
//                     ),
//                     if (_isLiked)
//                       Center(
//                         child: ScaleTransition(
//                           scale: _animation,
//                           child: Icon(
//                             Icons.favorite,
//                             color: Colors.red.withOpacity(0.8),
//                             size: 100,
//                           ),
//                         ),
//                       ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 12.0, bottom: 120),
//                       child: Align(
//                         alignment: Alignment.bottomRight,
//                         child: Container(
//                           width: 52,
//                           height: MediaQuery.of(context).size.width / 2,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(17),
//                             color: Colors.transparent.withAlpha(80),
//                             // boxShadow: [
//                             //   BoxShadow(
//                             //     color: Colors.grey.withOpacity(0.3),
//                             //     offset: const Offset(0, 2),
//                             //     blurRadius: 4,
//                             //     spreadRadius: 1,
//                             //   ),
//                             // ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               SizedBox(
//                                 height: 16,
//                               ),
//                               Container(
//                                 width: 40,
//                                 height: 40,
//                                 child: IconButton(
//                                   onPressed: () {
//                                     // handleLike();
//                                     setState(() {
//                                       _isLiked = !_isLiked;
//                                     });
//                                   },
//                                   icon: SvgPicture.asset(
//                                     'assets/icons/like_icon.svg',
//                                     color: _isLiked ? Colors.red : Colors.white,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 16,
//                               ),
//                               Container(
//                                 width: 40,
//                                 height: 40,
//                                 child: IconButton(
//                                     onPressed: () =>
//                                         showCommentBottomSheet(context),
//                                     icon: SvgPicture.asset(
//                                       'assets/icons/comment_icon.svg',
//                                       color: Colors.white,
//                                     )),
//                               ),
//                               const SizedBox(
//                                 height: 16,
//                               ),
//                               Container(
//                                 width: 40,
//                                 height: 40,
//                                 child: IconButton(
//                                     key: _buttonKey,
//                                     onPressed: () async {
//                                       // Get button's position
//                                       showPopupMenu();
//                                     },
//                                     icon: SvgPicture.asset(
//                                         'assets/icons/ping_icon.svg',
//                                         color: Colors.white)),
//                               ),
//                               SizedBox(
//                                 height: 16,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                         left: 16,
//                         right: 16,
//                         bottom: kToolbarHeight,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: AppColors.userProfileBorderColor,
//                                     width: 1,
//                                   )),
//                               child: const CircleAvatar(
//                                 radius: 33,
//                                 backgroundColor: AppColors.white,
//                                 child: CircleAvatar(
//                                   backgroundImage:
//                                       AssetImage('assets/images/user2.png'),
//                                   radius: 30,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Shalini Reddy',
//                                   style: AppFonts.titleBold(
//                                       color: AppColors.black, fontSize: 18),
//                                 ),
//                                 SizedBox(
//                                   height: 4,
//                                 ),
//                                 Text(
//                                   'Had a wonderful day near the brigade road\nvintage joke of the day',
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: AppFonts.titleMedium(
//                                       color: AppColors.black, fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         )),
//                   ],
//                 ),
//               );
//             },
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 30, left: 6),
//             child: Row(
//               children: [
//                 IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: Icon(
//                       Icons.arrow_back_ios,
//                       color: Colors.black,
//                       // size: 25,
//                     )),
//                 Positioned(
//                   top: kToolbarHeight,
//                   // left: 16,
//                   child: Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Positioned(
//                           top: 6,
//                           left: 46,
//                           child: SvgPicture.asset(
//                             'assets/icons/snip_icon.svg',
//                             width: 30,
//                             height: 30,
//                           )),
//                       Text(
//                         'Snip',
//                         style: AppFonts.titleBold(
//                           color: AppColors.black,
//                           fontSize: 28,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: kToolbarHeight,
//             right: 20,
//             child: InkWell(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => VideoCameraScreen(),
//                     ));
//               },
//               child: Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   SvgPicture.asset(
//                     'assets/icons/snip_camera_icon.svg',
//                     width: 40,
//                     height: 40,
//                   ),
//                   // Positioned(
//                   //     top: 20,
//                   //     left: 18,
//                   //     child: SvgPicture.asset(
//                   //       'assets/icons/snip_upload_icon.svg',
//                   //       width: 24,
//                   //       height: 24,
//                   //     )),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void showCommentBottomSheet(BuildContext context) async {
//     await showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(16.0),
//         ),
//       ),
//       isScrollControlled: true,
//       backgroundColor: AppColors.white.withOpacity(0.9),
//       builder: (context) {
//         return Padding(
//           padding: MediaQuery.of(context).viewInsets,
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Center(
//                       child: Container(
//                           width: 80,
//                           height: 16,
//                           child: SvgPicture.asset(
//                             'assets/icons/bottomsheet_top_icon.svg',
//                             // color: AppColors.black,
//                           ))),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(height: 16),
//                       Center(
//                         child: Text(
//                           'Comments',
//                           style: AppFonts.titleBold(color: AppColors.black),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         padding: EdgeInsets.zero,
//                         itemCount: 3,
//                         itemBuilder: (context, index) {
//                           // CommentModel comment = comments[index];
//                           return ListTile(
//                             visualDensity:
//                                 const VisualDensity(horizontal: 0, vertical: 0),
//                             contentPadding: EdgeInsets.zero,
//                             leading: ClipOval(
//                               child: Image.asset(
//                                   'assets/images/nitanshu_profile_image.png'),
//                             ),
//                             title: Text('Nitanshu'),
//                             titleTextStyle: AppFonts.titleBold(
//                                 fontSize: 14, color: AppColors.black),
//                             subtitle: Text('i want to be there next time'),
//                             subtitleTextStyle: AppFonts.titleMedium(
//                                 fontSize: 12, color: AppColors.black),
//                             trailing: Icon(
//                               Icons.replay,
//                               color: AppColors.black,
//                             ),
//                           );
//                         },
//                       ),
//                       ListTile(
//                         visualDensity:
//                             const VisualDensity(horizontal: 0, vertical: 0),
//                         contentPadding: EdgeInsets.only(left: 50),
//                         leading: ClipOval(
//                           child: Image.asset(
//                             'assets/images/user2.png',
//                             width: 32,
//                             height: 32,
//                           ),
//                         ),
//                         title: Text('sree'),
//                         titleTextStyle: AppFonts.titleBold(
//                             fontSize: 14, color: AppColors.black),
//                         subtitle: Text('see you soon'),
//                         subtitleTextStyle: AppFonts.titleMedium(
//                             fontSize: 12, color: AppColors.black),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 20),
//                   SizedBox(
//                     height: 48,
//                     child: TextFormField(
//                       controller: commentController,
//                       focusNode: commentFocusNode,

//                       style: AppFonts.titleMedium(color: AppColors.black),

//                       cursorHeight: 20,
//                       cursorColor: AppColors.black,
//                       // maxLength: 10,
//                       maxLines: 1,
//                       minLines: 1,
//                       onChanged: (value) {
//                         if (value.isNotEmpty) {
//                           setState(() {});
//                         }
//                       },

//                       keyboardType: TextInputType.text,
//                       decoration: InputDecoration(
//                         floatingLabelBehavior: FloatingLabelBehavior.never,
//                         contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                         hintText: 'Post your comment',
//                         hintStyle: AppFonts.hintTitle(color: AppColors.black),
//                         // suffix: Container(
//                         //   width: 40,
//                         //   height: 40,
//                         //   child: ElevatedButton(
//                         //     onPressed: () async {
//                         //       // await userProvider.addComment(
//                         //       //     widget.postId, _commentController.text);
//                         //
//                         //       ScaffoldMessenger.of(context).showSnackBar(
//                         //         SnackBar(
//                         //           content:
//                         //           Text('Comment added successfully!'),
//                         //           duration: Duration(seconds: 2),
//                         //         ),
//                         //       );
//                         //
//                         //       commentController.clear();
//                         //       Navigator.pop(context);
//                         //     },
//                         //     style: ButtonStyle(
//                         //         backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
//                         //       // fixedSize: WidgetStatePropertyAll(Size(36,24))
//                         //     ),
//                         //     child:  Icon(Icons.send,color: AppColors.white,),),
//                         // ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             Icons.send,
//                             color: AppColors.black,
//                           ),
//                           onPressed: () {
//                             // Handle send button press here
//                             String message = commentController.text;
//                             if (message.isNotEmpty) {
//                               // Send the message
//                               print("Sending message: $message");
//                               commentController.clear();
//                             }
//                           },
//                         ),

//                         enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(12)),
//                             borderSide: BorderSide(color: AppColors.black)),
//                         errorBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(12)),
//                             borderSide: BorderSide(color: AppColors.black)),
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(12)),
//                             borderSide: BorderSide(color: AppColors.black)),
//                         focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(12)),
//                             borderSide: BorderSide(color: AppColors.black)),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   // isFlag
//                   //     ? Row(
//                   //         mainAxisSize: MainAxisSize.max,
//                   //         mainAxisAlignment: MainAxisAlignment.end,
//                   //         children: [
//                   //           ElevatedButton(
//                   //             onPressed: () async {
//                   //               // await userProvider.addComment(
//                   //               //     widget.postId, _commentController.text);
//                   //
//                   //               ScaffoldMessenger.of(context).showSnackBar(
//                   //                 SnackBar(
//                   //                   content:
//                   //                       Text('Comment added successfully!'),
//                   //                   duration: Duration(seconds: 2),
//                   //                 ),
//                   //               );
//                   //
//                   //               commentController.clear();
//                   //               Navigator.pop(context);
//                   //             },
//                   //             style: ButtonStyle(
//                   //               backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)
//                   //             ),
//                   //             child:  Icon(Icons.send,color: AppColors.white,),),
//                   //
//                   //         ],
//                   //       )
//                   //     : SizedBox(),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void showPopupMenu() {
//     // Get button's position
//     final RenderBox button =
//         _buttonKey.currentContext!.findRenderObject() as RenderBox;
//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;
//     final RelativeRect position = RelativeRect.fromLTRB(
//       button.localToGlobal(Offset.zero, ancestor: overlay).dx, // X position
//       button.localToGlobal(Offset.zero, ancestor: overlay).dy -
//           button.size.height, // Y position above button
//       button.localToGlobal(Offset.zero, ancestor: overlay).dx +
//           button.size.width,
//       button.localToGlobal(Offset.zero, ancestor: overlay).dy,
//     );

//     showMenu(
//       context: context,
//       position: position,
//       items: [
//         PopupMenuItem<int>(
//           value: 0,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 4.0),
//                 child: Icon(Icons.message),
//               ),
//               SizedBox(
//                 width: 4,
//               ),
//               Text("Send Message"),
//             ],
//           ),
//         ),
//         PopupMenuItem<int>(
//           value: 1,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 4.0, left: 6),
//                 child: Icon(Icons.report),
//               ),
//               SizedBox(
//                 width: 4,
//               ),
//               Text("Report"),
//             ],
//           ),
//         ),
//         // PopupMenuItem<int>(
//         //   value: 1,
//         //   child: Text("Option 2"),
//         // ),
//         // PopupMenuItem<int>(
//         //   value: 2,
//         //   child: Text("Option 3"),
//         // ),
//       ],
//     ).then((value) {
//       if (value != null) {
//         if (value == 1) {
//           // ScaffoldMessenger.of(context).showSnackBar(
//           //   SnackBar(
//           //     content: Text('Reported successfully'),
//           //   ),
//           // );
//           Fluttertoast.showToast(
//               msg: "Reported successfully",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.TOP,
//               timeInSecForIosWeb: 1,
//               backgroundColor: Colors.black,
//               textColor: Colors.white,
//               fontSize: 16.0);

//           // Navigator.pop(context);
//         } else {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const MessengerPage(),
//               ));
//         }
//       }
//     });
//   }
// }
