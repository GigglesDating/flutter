import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/main.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class SnipTab extends StatefulWidget {
  const SnipTab({super.key});

  @override
  State<SnipTab> createState() => _SnipTab();
}

class _SnipTab extends State<SnipTab> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  CameraController? _cameraController;
  final bool _isCameraInitialized = false;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();
  final GlobalKey _buttonKey = GlobalKey();
  bool _isMuted = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLiked = false;

  void toggleVolume() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(
          _isMuted ? 0.0 : 1.0); // Set volume to 0.0 if muted, 1.0 if unmuted
      _controller.play();
    });
  }

  void pauser() {
    setState(() {
      _controller.pause();
      isPlaying = false;
      _isMuted = !_isMuted;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Make it transparent or choose any color
      statusBarIconBrightness: Brightness.light,
      // Set icons to white
      statusBarBrightness: Brightness.light, // For iOS
    ));
    _controller = VideoPlayerController.asset('assets/video/snip_reel.mp4');
    // _initializeVideoPlayerFuture = _controller.initialize();

    _controller.initialize().then((_) {
      // Start playing the video automatically
      _controller.play();
      setState(() {}); // Rebuild to show the video once initialized
    });
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _controller.seekTo(Duration.zero); // Restart the video
        _controller.play(); // Play it again
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  void onDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
      });
    }
    _animationController.forward().then((_) => _animationController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Make it transparent or choose any color
      statusBarIconBrightness: Brightness.light,
      // Set icons to white
      statusBarBrightness: Brightness.light, // For iOS
    ));
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            itemCount: 6,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: toggleVolume,
                onDoubleTap: onDoubleTap,
                onLongPress: pauser,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                    if (_isLiked)
                      Center(
                        child: ScaleTransition(
                          scale: _animation,
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red.withAlpha(150),
                            size: 100,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, bottom: 120),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 52,
                          height: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            color: Colors.transparent.withAlpha(150),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                  onPressed: () {
                                    // handleLike();
                                    setState(() {
                                      _isLiked = !_isLiked;
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/feed/like.svg',
                                    height: 50,
                                    color: _isLiked ? Colors.red : Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                    onPressed: () =>
                                        showCommentBottomSheet(context),
                                    icon: SvgPicture.asset(
                                      'assets/icons/feed/comment.svg',
                                      height: 50,
                                      color: Colors.white,
                                    )),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                    key: _buttonKey,
                                    onPressed: () async {
                                      // Get button's position
                                      showPopupMenu();
                                    },
                                    icon: SvgPicture.asset(
                                        'assets/icons/feed/ping_icon.svg',
                                        height: 50,
                                        color: Colors.white)),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        left: 16,
                        right: 16,
                        bottom: kToolbarHeight + kToolbarHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 148, 177, 67),
                                    width: 1,
                                  )),
                              child: const CircleAvatar(
                                radius: 33,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'assets/tempImages/users/user2.jpg'),
                                  radius: 30,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Shalini Reddy',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    )),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Had a wonderful day near the brigade \nroad vintage joke of the day',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 6),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      // size: 25,
                    )),
                Positioned(
                  top: kToolbarHeight,
                  // left: 16,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                          top: 6,
                          left: 46,
                          child: SvgPicture.asset(
                            'assets/icons/snip_icon.svg',
                            width: 30,
                            height: 30,
                          )),
                      Text('Snip',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: kToolbarHeight,
            right: 20,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceholderScreen(
                          message: "placeHolder", screenName: "Video_screen"),
                    ));
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    'assets/icons/feed/snip_camera_icon.svg',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showCommentBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white.withOpacity(0.9),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                      child: SizedBox(
                          width: 80,
                          height: 16,
                          child: SvgPicture.asset(
                            'assets/icons/feed/bottomsheet_top_icon.svg',
                          ))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Comments',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return ListTile(
                            visualDensity:
                                const VisualDensity(horizontal: 0, vertical: 0),
                            contentPadding: EdgeInsets.zero,
                            leading: ClipOval(
                              child: Image.asset(
                                  'assets/tempImages/users/user1.jpg'),
                            ),
                            title: Text('Nitanshu'),
                            titleTextStyle:
                                TextStyle(fontSize: 14, color: Colors.black),
                            subtitle: Text('i want to be there next time'),
                            subtitleTextStyle:
                                TextStyle(fontSize: 12, color: Colors.black),
                            trailing: Icon(
                              Icons.replay,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: 0),
                        contentPadding: EdgeInsets.only(left: 50),
                        leading: ClipOval(
                          child: Image.asset(
                            'assets/tempImages/users/user2.jpg',
                            width: 32,
                            height: 32,
                          ),
                        ),
                        title: Text('sree'),
                        titleTextStyle:
                            TextStyle(fontSize: 14, color: Colors.black),
                        subtitle: Text('see you soon'),
                        subtitleTextStyle:
                            TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: TextFormField(
                      controller: commentController,
                      focusNode: commentFocusNode,

                      style: TextStyle(color: Colors.black),

                      cursorHeight: 20,
                      cursorColor: Colors.black,
                      // maxLength: 10,
                      maxLines: 1,
                      minLines: 1,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {});
                        }
                      },

                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Post your comment',
                        hintStyle: TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            // Handle send button press here
                            String message = commentController.text;
                            if (message.isNotEmpty) {
                              // Send the message
                              commentController.clear();
                            }
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.black)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.black)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.black)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showPopupMenu() {
    // Get button's position
    final RenderBox button =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromLTRB(
      button.localToGlobal(Offset.zero, ancestor: overlay).dx, // X position
      button.localToGlobal(Offset.zero, ancestor: overlay).dy -
          button.size.height, // Y position above button
      button.localToGlobal(Offset.zero, ancestor: overlay).dx +
          button.size.width,
      button.localToGlobal(Offset.zero, ancestor: overlay).dy,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(Icons.message),
              ),
              SizedBox(
                width: 4,
              ),
              Text("Send Message"),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 6),
                child: Icon(Icons.report),
              ),
              SizedBox(
                width: 4,
              ),
              Text("Report"),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        if (value == 1) {
          Fluttertoast.showToast(
              msg: "Reported successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceholderScreen(
                  message: "placeHolder",
                  screenName: "messanger_screen",
                ),
              ));
        }
      }
    });
  }
}
