import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';
import '../barrel.dart';

class SnipTab extends StatefulWidget {
  const SnipTab({super.key});

  @override
  State<SnipTab> createState() => _SnipTab();
}

class _SnipTab extends State<SnipTab>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late List<VideoPlayerController?> _controllers;
  int _currentVideoIndex = 0;
  bool isPlaying = false;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();
  final GlobalKey _buttonKey = GlobalKey();
  bool _isMuted = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLiked = false;
  final int _preloadLimit = 2;
  bool _isActive = false;
  bool _showHeart = false;

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
    _setupAnimationController();
    _initializeControllers();
  }

  void _setupAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
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
      _initializeControllers();
    }
  }

  void _deactivate() {
    if (_isActive) {
      _isActive = false;
      _disposeControllers();
    }
  }

  void _disposeControllers() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _controllers = List.generate(videoAssets.length, (_) => null);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App is in background or navigated away
      for (var controller in _controllers) {
        controller?.pause();
      }
      setState(() {
        isPlaying = false;
      });
    }
  }

  void _initializeControllers() {
    _controllers = List.generate(videoAssets.length, (_) => null);
    _initializeControllerAtIndex(0);
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    if (index < 0 || index >= _controllers.length) return;

    await _controllers[index]?.dispose();

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
      }
    } catch (e) {
      debugPrint('Error initializing video at index $index: $e');
    }
  }

  void toggleVolume() {
    setState(() {
      _isMuted = !_isMuted;
      _controllers[_currentVideoIndex]?.setVolume(_isMuted ? 0.0 : 1.0);
      _controllers[_currentVideoIndex]?.play();
    });
  }

  void pauser() {
    setState(() {
      _isMuted = !_isMuted;
      _controllers[_currentVideoIndex]?.pause();
      isPlaying = false;
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
        setState(() => _showHeart = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text(
              'Snip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // TODO: Implement video upload
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(38),
                ),
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: _showReportSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(25),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        itemCount: videoAssets.length,
        scrollDirection: Axis.vertical,
        onPageChanged: _handlePageChange,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: toggleVolume,
            onDoubleTap: onDoubleTap,
            onLongPress: pauser,
            child: Stack(
              children: [
                // Video player
                SizedBox.expand(
                  child: _controllers[index]?.value.isInitialized ?? false
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controllers[index]!.value.size.width,
                            height: _controllers[index]!.value.size.height,
                            child: VideoPlayer(_controllers[index]!),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),

                // Action bar
                Positioned(
                  right: 8,
                  bottom: MediaQuery.of(context).size.height * 0.15,
                  child: ActionBar(
                    isDarkMode: true,
                    isLiked: _isLiked,
                    onLikeTap: () {
                      setState(() {
                        _isLiked = !_isLiked;
                      });
                    },
                    onCommentTap: () => showCommentBottomSheet(context),
                    onShareTap: _showShareSheet,
                  ),
                ),

                // Heart Animation
                if (_showHeart)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showHeart ? 1.0 : 0.0,
                      child: Center(
                        child: ScaleTransition(
                          scale: _animation,
                          child: Icon(
                            Icons.favorite,
                            color: Colors.white.withAlpha(255),
                            size: MediaQuery.of(context).size.width * 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void showCommentBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(128),
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
    for (var controller in _controllers) {
      controller?.dispose();
    }
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handlePageChange(int index) async {
    // Pause current video
    await _controllers[_currentVideoIndex]?.pause();

    // Dispose controllers outside the preload range
    for (var i = 0; i < _controllers.length; i++) {
      if (i < index - _preloadLimit || i > index + _preloadLimit) {
        await _controllers[i]?.dispose();
        setState(() {
          _controllers[i] = null;
        });
      }
    }

    // Initialize videos within preload range
    for (var i = index - _preloadLimit; i <= index + _preloadLimit; i++) {
      if (i >= 0 &&
          i < videoAssets.length &&
          (_controllers[i]?.value.isInitialized ?? false) == false) {
        await _initializeControllerAtIndex(i);
      }
    }

    setState(() {
      _currentVideoIndex = index;
    });

    // Play new video
    await _controllers[index]?.play();
  }

  void _showShareSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareSheet(
        isDarkMode: isDarkMode,
        post: {
          'type': 'snip',
          'url': videoAssets[_currentVideoIndex],
        },
        screenWidth: MediaQuery.of(context).size.width,
      ),
    );
  }

  void _showReportSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportSheet(
        isDarkMode: isDarkMode,
        screenWidth: screenWidth,
      ),
    );
  }
}
