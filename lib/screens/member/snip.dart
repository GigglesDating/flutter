import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screens/member/home.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class SnipTab extends StatefulWidget {
  const SnipTab({super.key});

  @override
  State<SnipTab> createState() => _SnipTab();
}

class _SnipTab extends State<SnipTab>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late List<VideoPlayerController> _controllers;
  int _currentVideoIndex = 0;
  bool isPlaying = false;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();
  final GlobalKey _buttonKey = GlobalKey();
  bool _isMuted = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      // Make it transparent or choose any color
      statusBarIconBrightness: Brightness.light,
      // Set icons to white
      statusBarBrightness: Brightness.light, // For iOS
    ));
    _initializeVideoControllers();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App is in background or navigated away
      for (var controller in _controllers) {
        controller.pause();
      }
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  void deactivate() {
    // Called when this screen is removed from the navigation stack
    for (var controller in _controllers) {
      controller.pause();
    }
    setState(() {
      isPlaying = false;
    });
    super.deactivate();
  }

  Future<void> _initializeVideoControllers() async {
    // Initialize list of video controllers
    _controllers = [
      VideoPlayerController.asset('assets/video/1.mp4'),
      VideoPlayerController.asset('assets/video/2.mp4'),
    ];

    // Initialize all controllers
    for (var controller in _controllers) {
      await controller.initialize();
      controller.setLooping(true);
    }

    // Start playing the first video
    if (_controllers.isNotEmpty) {
      _controllers[0].play();
      isPlaying = true;
    }

    setState(() {});
  }

  void toggleVolume() {
    setState(() {
      _isMuted = !_isMuted;
      _controllers[_currentVideoIndex].setVolume(_isMuted ? 0.0 : 1.0);
      _controllers[_currentVideoIndex].play();
    });
  }

  void pauser() {
    setState(() {
      _isMuted = !_isMuted;
      _controllers[_currentVideoIndex].pause();
      isPlaying = false;
    });
  }

  void _playNextVideo() {
    _controllers[_currentVideoIndex].pause();
    _currentVideoIndex = (_currentVideoIndex + 1) % _controllers.length;
    _controllers[_currentVideoIndex].play();
    setState(() {
      isPlaying = true;
    });
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
            itemCount: _controllers.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              for (var controller in _controllers) {
                if (controller.value.isPlaying) {
                  controller.pause();
                }
              }
              setState(() {
                _currentVideoIndex = index;
                _controllers[_currentVideoIndex].play();
                isPlaying = true;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: toggleVolume,
                onDoubleTap: onDoubleTap,
                onLongPress: pauser,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _controllers[index].value.isInitialized
                          ? FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controllers[index].value.size.width,
                                height: _controllers[index].value.size.height,
                                child: VideoPlayer(_controllers[index]),
                              ),
                            )
                          : Center(child: CircularProgressIndicator()),
                    ),
                    if (_isLiked)
                      Center(
                        child: ScaleTransition(
                          scale: _animation,
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red.withOpacity(0.8),
                            size: 100,
                          ),
                        ),
                      ),
                    Positioned(
                        left: 16,
                        right: 16,
                        bottom: kToolbarHeight,
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
                                  'Had a wonderful day near the brigade road\nvintage joke of the day',
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
                      for (var controller in _controllers) {
                        controller.pause();
                      }
                      setState(() {
                        isPlaying = false;
                      });
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
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
                for (var controller in _controllers) {
                  controller.pause();
                }
                setState(() {
                  isPlaying = false;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeTab(),
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
                            'assets/icons/bottomsheet_top_icon.svg',
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
                                  'assets/images/nitanshu_profile_image.png'),
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
                            'assets/images/user2.png',
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
                              print("Sending message: $message");
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
                builder: (context) => const Placeholder(),
              ));
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (var controller in _controllers) {
      controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }
}
