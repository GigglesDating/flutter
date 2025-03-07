import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../barrel.dart';

class SnipTab extends StatefulWidget {
  const SnipTab({super.key});

  @override
  State<SnipTab> createState() => _SnipTabState();
}

class _SnipTabState extends State<SnipTab>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List<VideoPlayerController?> _controllers = [];
  int _currentVideoIndex = 0;
  bool _isMuted = false;
  bool _isLiked = false;
  bool _showHeart = false;
  bool isPlaying = true;
  final _buttonKey = GlobalKey();
  late AnimationController _animationController;
  final int _preloadLimit = 1; // Preload one video on each side
  bool _isActive = false;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();

  // Local video assets
  final List<String> videoAssets = [
    'assets/video/1.mp4',
    'assets/video/2.mp4',
    'assets/video/3.mp4',
  ];

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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we're the active route
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      _activate();
    } else {
      _deactivate();
    }
  }

  void _activate() {
    if (!_isActive) {
      _isActive = true;
      // Only re-initialize if controllers are not already initialized.
      if (_controllers.isEmpty || _controllers[_currentVideoIndex] == null) {
        _initializeControllers();
      } else {
        // If already initialized, just play.
        _controllers[_currentVideoIndex]?.play();
      }
    }
  }

  void _deactivate() {
    if (_isActive) {
      _isActive = false;
      // Pause, but *don't* dispose, unless outside preload limit.
      _pauseCurrentController();
    }
  }

  void _pauseCurrentController() {
    if (_controllers[_currentVideoIndex] != null) {
      _controllers[_currentVideoIndex]?.pause();
      setState(() {
        isPlaying = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App is in background or navigated away
      _pauseCurrentController(); // Use the helper function
    }
    if (state == AppLifecycleState.resumed) {
      // App is back in foreground.  Play *only* if we are the active route.
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        _controllers[_currentVideoIndex]?.play();
        setState(() {
          isPlaying = true;
        });
      }
    }
  }

  void _initializeControllers() {
    _controllers = List.generate(videoAssets.length, (_) => null);
    _initializeControllerAtIndex(0);
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    if (index < 0 || index >= _controllers.length) return;

    // Dispose only if it exists and is initialized.
    if (_controllers[index] != null) {
      await _controllers[index]!.dispose();
    }

    try {
      final controller = VideoPlayerController.asset(videoAssets[index]);
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controllers[index] = controller;
      });

      controller.setLooping(true);
      controller.setVolume(_isMuted ? 0.0 : 1.0);

      if (index == _currentVideoIndex) {
        controller.play();
        setState(() {
          isPlaying = true; // Ensure isPlaying is updated
        });
      }
    } catch (e) {
      debugPrint('Error initializing video at index $index: $e');
    }
  }

  Future<void> toggleVolume() async {
    if (_controllers[_currentVideoIndex] == null) return;
    final newVolume = _isMuted ? 1.0 : 0.0;
    await _controllers[_currentVideoIndex]!.setVolume(newVolume);
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void onDoubleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
      _showHeart = true;
    });
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        setState(() {
          _showHeart = false;
        });
      });
    });
  }

  void pauser() {
    setState(() {
      _isMuted = !_isMuted;
      _controllers[_currentVideoIndex]?.pause();
      isPlaying = false;
    });
  }

  void togglePlay() {
    if (_controllers[_currentVideoIndex] != null) {
      if (isPlaying) {
        _controllers[_currentVideoIndex]?.pause();
      } else {
        _controllers[_currentVideoIndex]?.play();
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Snip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.white.withAlpha(80)
                    : Colors.black.withAlpha(26),
              ),
              child: SvgPicture.asset(
                'assets/icons/snip/snip_upload.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? Colors.white : Colors.black.withAlpha(204),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.white.withAlpha(80)
                    : Colors.black.withAlpha(26),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color:
                      isDarkMode ? Colors.white : Colors.black.withAlpha(204),
                  size: 24,
                ),
                onPressed: _showReportSheet,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen PageView for videos
          Positioned.fill(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videoAssets.length,
              onPageChanged: _handlePageChange,
              itemBuilder: (context, index) {
                return VisibilityDetector(
                  key: Key('video_$index'),
                  onVisibilityChanged: (visibilityInfo) {
                    if (mounted) {
                      if (visibilityInfo.visibleFraction > 0.8) {
                        if (index == _currentVideoIndex &&
                            (ModalRoute.of(context)?.isCurrent ?? false)) {
                          _controllers[index]?.play();
                          setState(() {
                            isPlaying = true;
                          });
                        }
                      } else {
                        _controllers[index]?.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      }
                    }
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (!isPlaying) {
                        // If video is paused, resume on tap
                        togglePlay();
                      } else {
                        // If video is playing, toggle mute/unmute
                        toggleVolume();
                      }
                    },
                    onDoubleTap: onDoubleTap, // Keep double tap for like/unlike
                    onLongPress: () {
                      if (isPlaying) {
                        // Only pause if video is currently playing
                        togglePlay();
                      }
                    },
                    child: Container(
                      color: Colors.black,
                      child: Stack(
                        children: [
                          // Video Player with proper sizing
                          if (_controllers[index] != null &&
                              _controllers[index]!.value.isInitialized)
                            Container(
                              color: Colors.black,
                              child: Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    clipBehavior: Clip.hardEdge,
                                    child: SizedBox(
                                      width:
                                          _controllers[index]!.value.size.width,
                                      height: _controllers[index]!
                                          .value
                                          .size
                                          .height,
                                      child: VideoPlayer(_controllers[index]!),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),

                          // Like animation overlay
                          if (_showHeart)
                            Center(
                              child: FadeTransition(
                                opacity: _animationController,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 100,
                                ),
                              ),
                            ),

                          // Action bar
                          Positioned(
                            right: MediaQuery.of(context).size.width * 0.02,
                            bottom: MediaQuery.of(context).size.height * 0.15,
                            child: ActionBar(
                              isDarkMode: isDarkMode,
                              isLiked: _isLiked,
                              onLikeTap: onDoubleTap,
                              onCommentTap: () =>
                                  showCommentBottomSheet(context),
                              onShareTap: _showShareSheet,
                              orientation: ActionBarOrientation.vertical,
                              backgroundColor: isDarkMode
                                  ? Colors.black.withAlpha(230)
                                  : Colors.white.withAlpha(230),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showCommentBottomSheet(BuildContext context) {
    // Pause video and store current position
    _controllers[_currentVideoIndex]?.pause();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0),
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CommentsSheet(
          isDarkMode: isDarkMode,
          post: {
            'id': _currentVideoIndex.toString(),
            'type': 'snip',
            'url': videoAssets[_currentVideoIndex],
          },
          screenHeight: screenHeight,
          screenWidth: screenWidth,
        ),
      ),
    ).then((_) {
      if (mounted) {
        // Resume from stored position
        _controllers[_currentVideoIndex]?.play();
        setState(() {
          isPlaying = true;
        });
      }
    });
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
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handlePageChange(int index) async {
    // Pause the *current* video.
    _pauseCurrentController();

    // Dispose controllers *outside* the preload range.
    for (var i = 0; i < _controllers.length; i++) {
      if (i < index - _preloadLimit || i > index + _preloadLimit) {
        if (_controllers[i] != null) {
          await _controllers[i]!.dispose();
          setState(() {
            _controllers[i] = null;
          });
        }
      }
    }

    // Initialize videos *within* preload range.
    for (var i = index - _preloadLimit; i <= index + _preloadLimit; i++) {
      if (i >= 0 && i < videoAssets.length && _controllers[i] == null) {
        await _initializeControllerAtIndex(i);
      }
    }

    setState(() {
      _currentVideoIndex = index;
    });

    // Play the *new* current video.
    _controllers[index]?.play();
    setState(() {
      isPlaying = true;
    });
  }

  void _showShareSheet() {
    // Pause the video *before* showing the bottom sheet.
    _controllers[_currentVideoIndex]?.pause();
    setState(() {
      isPlaying = false;
    });

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0),
      builder: (context) => ShareSheet(
        isDarkMode: isDarkMode,
        post: {
          'type': 'snip',
          'url': videoAssets[_currentVideoIndex],
        },
        screenWidth: MediaQuery.of(context).size.width,
      ),
    ).then((_) {
      // Resume playback *after* the bottom sheet is closed.
      if (mounted) {
        // Crucially, *remove* the seekTo. Just play.
        _controllers[_currentVideoIndex]?.play();
        setState(() {
          isPlaying = true;
        });
      }
    });
  }

// alright, lets remove the whole code in this file... we'll implement a new login... this login will have a container with a video player, the size of it will be potrait and cover approx 77% of the screen center alligned adn width till the edges of the phone...

// the action_bar dart must be called here adn we will implement it the same way as we have done in post_card dart... we will place the action bar slightly lower than middle to the right corner on the video player container, it must be overlayed on the video...

// finally we'll have a 3 dots button with a small round container in the same color, contrast adn dark / light mode settings as as the icons in actions bar ...

// we will place this 3 dots button on the video .. at the top right corner...

  void _showReportSheet() {
    // Pause *before* showing the sheet.
    _controllers[_currentVideoIndex]?.pause();
    setState(() {
      isPlaying = false;
    });

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor:
          Colors.black.withValues(alpha: 128, red: 0, green: 0, blue: 0),
      builder: (context) => ContentReportSheet(
        isDarkMode: isDarkMode,
        screenWidth: screenWidth,
      ),
    ).then((_) {
      // Resume *after* the sheet is closed.
      if (mounted) {
        // *Remove* seekTo.
        _controllers[_currentVideoIndex]?.play();
        setState(() {
          isPlaying = true;
        });
      }
    });
  }

  // double _getVideoScale(Size videoSize, Size screenSize) {
  //   final videoRatio = videoSize.width / videoSize.height;
  //   final screenRatio = screenSize.width / screenSize.height;

  //   // If video is in landscape and we want portrait
  //   if (videoRatio > 1) {
  //     // Scale based on height to force portrait
  //     return screenSize.height / (videoSize.width / screenRatio);
  //   }

  //   // If video is already in portrait
  //   final scale = screenRatio / videoRatio;
  //   return scale > 1 ? scale : 1.0;
  // }
}
