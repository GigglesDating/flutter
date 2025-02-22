import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../barrel.dart';

class SnipCard extends StatefulWidget {
  final String videoUrl;
  final Map<String, dynamic> userInfo;
  final bool isVisible;
  final Animation<double> animation;

  const SnipCard({
    super.key,
    required this.videoUrl,
    required this.userInfo,
    required this.isVisible,
    required this.animation,
  });

  @override
  State<SnipCard> createState() => _SnipCardState();
}

class _SnipCardState extends State<SnipCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLiked = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(SnipCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isVisible && widget.isVisible) {
      _initializeVideo();
    } else if (oldWidget.isVisible && !widget.isVisible) {
      _cleanup();
    }
  }

  Future<void> _initializeVideo() async {
    if (_isInitialized) return;

    debugPrint('Initializing video: ${widget.videoUrl}');
    try {
      final controller = VideoPlayerController.asset(widget.videoUrl);
      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });

      controller.setLooping(true);
      controller.setVolume(_isMuted ? 0.0 : 1.0);

      if (widget.isVisible) {
        await controller.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _controller = null;
        });
      }
    }
  }

  void _cleanup() async {
    final controller = _controller;
    if (controller != null) {
      try {
        await controller.pause();
        await controller.dispose();
      } catch (e) {
        debugPrint('Error during cleanup: $e');
      }
      if (mounted) {
        setState(() {
          _controller = null;
          _isInitialized = false;
          _isLiked = false;
          _isMuted = false;
        });
      }
    }
  }

  void togglePlay() {
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    } else {
      _controller?.play();
    }
  }

  void toggleVolume() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    setState(() => _isLiked = !_isLiked);
  }

  void _showCommentsSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Add your comments list here
          ],
        ),
      ),
    );
  }

  void _showShareSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            // Add your share options here
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Error loading video',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: toggleVolume,
      onDoubleTap: () {
        if (!_isLiked) {
          setState(() => _isLiked = true);
        }
      },
      onLongPress: togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Like animation
          if (_isLiked)
            Center(
              child: ScaleTransition(
                scale: widget.animation,
                child: Icon(
                  Icons.favorite,
                  color: Colors.red.withAlpha(100),
                  size: 100,
                ),
              ),
            ),

          // Action bar and user info
          Positioned(
            right: MediaQuery.of(context).size.width * 0.02,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: ActionBar(
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
              isLiked: _isLiked,
              onLikeTap: _toggleLike,
              onCommentTap: _showCommentsSheet,
              onShareTap: _showShareSheet,
              orientation: ActionBarOrientation.vertical,
              backgroundColor: Colors.black.withAlpha(50),
            ),
          ),

          // User Info
          Positioned(
            left: 16,
            right: MediaQuery.of(context).size.width * 0.2,
            bottom: MediaQuery.of(context).size.height * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userInfo['username'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.userInfo['description'] != null)
                  Text(
                    widget.userInfo['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
