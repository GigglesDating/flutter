import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../barrel.dart';

class SnipTab extends StatefulWidget {
  const SnipTab({super.key});

  @override
  State<SnipTab> createState() => _SnipTabState();
}

class _SnipTabState extends State<SnipTab> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _currentPage = 0;
  bool _isVisible = false;

  @override
  bool get wantKeepAlive => false;

  final List<Map<String, dynamic>> _snips = [
    {
      'videoUrl': 'assets/video/1.mp4',
      'userInfo': {
        'username': 'Sarah Something',
        'profileImage': 'assets/tempImages/users/user1.png',
        'description': 'This is my first snip! 🎉',
      }
    },
    {
      'videoUrl': 'assets/video/2.mp4',
      'userInfo': {
        'username': 'Sarah Something',
        'profileImage': 'assets/tempImages/users/user1.png',
        'description': 'This is my first snip! 🎉',
      }
    },
    // {
    //   'videoUrl': 'https://your-s3-bucket.com/videos/example.mp4',
    //   'isLocalAsset': false,
    //   'userInfo': {
    //     'username': 'John Doe',
    //     'profileImage': 'assets/tempImages/users/user2.png',
    //     'description': 'Check out this amazing view!',
    //   }
    // },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final navState =
        context.findAncestorStateOfType<NavigationControllerState>();
    if (navState != null) {
      final isSnipTab = navState.currentIndex == 3;

      if (isSnipTab != _isVisible) {
        setState(() => _isVisible = isSnipTab);
        if (isSnipTab) {
          _initializeVideo(_currentPage);
        } else {
          _cleanup();
        }
      }
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (!_isVisible || index >= _snips.length) return;

    _cleanup();

    try {
      final controller = VideoPlayerController.asset(_snips[index]['videoUrl']);
      await controller.initialize();

      if (!mounted || !_isVisible) {
        controller.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: true,
        aspectRatio: 9 / 16,
        showControls: false,
        showOptions: false,
      );

      setState(() {
        _videoController = controller;
        _chewieController = chewieController;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _cleanup() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  @override
  void dispose() {
    _cleanup();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          _initializeVideo(page);
        },
        itemCount: _snips.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Center(
                child: _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : const CircularProgressIndicator(color: Colors.white),
              ),
              // User Info Overlay
              Positioned(
                bottom: 80,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _snips[index]['userInfo']['username'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _snips[index]['userInfo']['description'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
