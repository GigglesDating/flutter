import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/snip_model.dart';
import '../barrel.dart';

class ReelCard extends StatefulWidget {
  final SnipModel snip;
  final bool isDarkMode;
  final Function()? onNext;
  final Function()? onPrevious;
  final int index;

  const ReelCard({
    required this.snip,
    required this.isDarkMode,
    required this.index,
    this.onNext,
    this.onPrevious,
    super.key,
  });

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isLiked = false;
  bool _isMuted = false;
  bool _isPlaying = true;
  String? _error;

  Future<VideoPlayerController> _initializeVideoController() async {
    try {
      // First attempt with default settings
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.snip.video.url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );
      await controller.initialize();
      return controller;
    } catch (e) {
      debugPrint('Initial video initialization error: $e');

      // Second attempt with lower quality settings
      try {
        final fallbackController = VideoPlayerController.networkUrl(
          Uri.parse(widget.snip.video.url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
        await fallbackController.initialize();
        return fallbackController;
      } catch (e) {
        debugPrint('Fallback video initialization error: $e');

        // Final attempt with basic settings
        final basicController = VideoPlayerController.networkUrl(
          Uri.parse(widget.snip.video.url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
          ),
        );
        await basicController.initialize();
        return basicController;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _controller = await _initializeVideoController();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _controller.setLooping(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to play video';
        });
      }
      debugPrint('Video player error: $e');
    }
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(
        isDarkMode: widget.isDarkMode,
        contentId: widget.snip.snipId,
        contentType: 'snip',
        commentIds: widget.snip.commentIds,
        authorProfile: widget.snip.authorProfile,
        screenHeight: MediaQuery.of(context).size.height,
        screenWidth: MediaQuery.of(context).size.width,
      ),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(128),
      builder: (context) => ShareSheet(
        isDarkMode: widget.isDarkMode,
        post: {
          'type': 'snip',
          'url': widget.snip.video.url,
        },
        screenWidth: MediaQuery.of(context).size.width,
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    });
  }

  void _handleTap() {
    if (!_isPlaying) {
      // If video is paused, resume on tap
      _togglePlayPause();
    } else {
      // If video is playing, toggle mute/unmute
      _toggleMute();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: widget.snip.video.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const CircularProgressIndicator(color: Colors.white),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Center(
        child: CachedNetworkImage(
          imageUrl: widget.snip.video.thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const CircularProgressIndicator(color: Colors.white),
          errorWidget: (context, url, error) =>
              const CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          widget.onPrevious?.call();
        } else if (details.primaryVelocity! < 0) {
          widget.onNext?.call();
        }
      },
      onLongPress: _togglePlayPause,
      onTap: _handleTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Player
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),

            // Mute indicator (shows briefly when mute state changes)
            if (_isMuted)
              Icon(
                Icons.volume_off,
                color: Colors.white.withValues(alpha: 128),
                size: 32,
              ),

            // Action Bar
            Positioned(
              right: 10,
              bottom: MediaQuery.of(context).size.height * 0.2,
              child: ActionBar(
                isDarkMode: widget.isDarkMode,
                isLiked: _isLiked,
                onLikeTap: _handleLike,
                onCommentTap: _showCommentsSheet,
                onShareTap: _showShareSheet,
                orientation: ActionBarOrientation.vertical,
                backgroundColor: widget.isDarkMode
                    ? Colors.black.withValues(alpha: 230)
                    : Colors.white.withValues(alpha: 230),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
