import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../models/snips_model.dart';
import '../../models/utils/video_service.dart';
import '../../models/utils/snip_cache_manager.dart';
import '../../models/utils/snip_parser.dart';

class SnipCard extends StatefulWidget {
  final SnipModel snip;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isVisible;
  final bool autoPlay;

  const SnipCard({
    super.key,
    required this.snip,
    this.onLike,
    this.onComment,
    this.onShare,
    this.isVisible = false,
    this.autoPlay = false,
  });

  @override
  State<SnipCard> createState() => _SnipCardState();
}

class _SnipCardState extends State<SnipCard>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isBuffering = false;
  bool _hasError = false;
  String? _errorMessage;
  late AnimationController _likeAnimation;
  bool _isLiked = false;
  bool _showQualitySelector = false;
  final Duration _seekAmount = const Duration(seconds: 10);
  String _networkQuality = 'Auto';
  bool _showAnalytics = false;
  final Map<String, dynamic> _videoAnalytics = {
    'bufferCount': 0,
    'totalBufferTime': 0.0,
    'playbackStartTime': null,
    'qualitySwitches': 0,
    'errors': 0,
  };

  @override
  void initState() {
    super.initState();
    _likeAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });

      // Initialize video controller
      final controller =
          await VideoService.initializeController(widget.snip.video.source);
      if (controller == null || !mounted) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Failed to initialize video';
          });
        }
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
        _isMuted = false;
      });

      // Listen for buffering status
      _controller?.addListener(_onControllerUpdate);

      if (widget.autoPlay && widget.isVisible) {
        _playVideo();
      }

      // Preload thumbnail if available
      if (widget.snip.video.thumbnail != null) {
        await SnipCacheManager().preloadThumbnail(widget.snip.video.thumbnail);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    final controller = _controller;
    if (controller == null) return;

    // Check buffering state
    final bool isBuffering = controller.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() => _isBuffering = isBuffering);
    }

    // Check for playback errors
    if (controller.value.hasError && !_hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Playback error: ${controller.value.errorDescription}';
      });
    }

    _updateVideoAnalytics('buffer', isBuffering);
  }

  void _updateVideoAnalytics(String metric, [dynamic value]) {
    setState(() {
      switch (metric) {
        case 'buffer':
          _videoAnalytics['bufferCount']++;
          break;
        case 'bufferTime':
          _videoAnalytics['totalBufferTime'] += value as double;
          break;
        case 'qualitySwitch':
          _videoAnalytics['qualitySwitches']++;
          break;
        case 'error':
          _videoAnalytics['errors']++;
          break;
      }
    });
  }

  void _playVideo() {
    if (_controller?.value.isInitialized ?? false) {
      _controller?.play();
      setState(() => _isPlaying = true);
    }
  }

  void _pauseVideo() {
    if (_controller?.value.isInitialized ?? false) {
      _controller?.pause();
      setState(() => _isPlaying = false);
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  void _toggleMute() {
    if (_controller?.value.isInitialized ?? false) {
      final newVolume = _isMuted ? 1.0 : 0.0;
      _controller?.setVolume(newVolume);
      setState(() => _isMuted = !_isMuted);
    }
  }

  void _handleDoubleTapSeek(TapDownDetails details, bool forward) {
    if (!_isInitialized || _hasError || _controller == null) return;

    final screenWidth = context.size?.width ?? 0;
    final tapPosition = details.globalPosition.dx;

    // Only seek if tap is in the outer thirds of the screen
    if (tapPosition < screenWidth / 3 || tapPosition > (screenWidth * 2 / 3)) {
      final currentPosition = _controller!.value.position;
      final targetPosition = forward
          ? currentPosition + _seekAmount
          : currentPosition - _seekAmount;

      _controller!.seekTo(targetPosition);

      // Show seeking indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(forward
              ? 'Forward ${_seekAmount.inSeconds}s'
              : 'Backward ${_seekAmount.inSeconds}s'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black.withAlpha(179), // 0.7 opacity
        ),
      );
    }
  }

  void _toggleQualitySelector() {
    setState(() => _showQualitySelector = !_showQualitySelector);
  }

  void _toggleAnalytics() {
    setState(() => _showAnalytics = !_showAnalytics);
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.5) {
      if (!_isPlaying && widget.autoPlay) {
        _playVideo();
      }
    } else {
      if (_isPlaying) {
        _pauseVideo();
      }
    }
  }

  @override
  void didUpdateWidget(SnipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        if (widget.autoPlay) _playVideo();
      } else {
        _pauseVideo();
      }
    }
  }

  @override
  void dispose() {
    VideoService.clearPreloadedVideos();
    _controller?.removeListener(_onControllerUpdate);
    VideoService.disposeController(widget.snip.video.source);
    _likeAnimation.dispose();
    super.dispose();
  }

  Widget _buildProgressBar() {
    return SizedBox(
      height: 2.0,
      child: VideoProgressIndicator(
        _controller!,
        allowScrubbing: true,
        padding: EdgeInsets.zero,
        colors: VideoProgressColors(
          playedColor: Colors.white,
          bufferedColor: Colors.white.withAlpha((0.2 * 255).round()),
          backgroundColor: Colors.grey[800]!,
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black.withAlpha(179), // 0.7 opacity
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Video playback error',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeVideo,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferingOverlay() {
    return Container(
      color: Colors.black.withAlpha(77), // 0.3 opacity
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildQualitySelector() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      right: 16,
      bottom: _showQualitySelector ? 100 : -200,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(204), // 0.8 opacity
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('Auto', true),
            _buildQualityOption('1080p', false),
            _buildQualityOption('720p', false),
            _buildQualityOption('480p', false),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(String quality, bool isSelected) {
    return InkWell(
      onTap: () => _switchQuality(quality),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              quality,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check, color: Colors.blue, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkQualityIndicator() {
    IconData icon;
    Color color;

    if (_hasError) {
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (_isBuffering) {
      icon = Icons.running_with_errors;
      color = Colors.orange;
    } else {
      icon = Icons.network_check;
      color = Colors.green;
    }

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(153), // 0.6 opacity
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              _networkQuality,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsOverlay() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      left: 16,
      bottom: _showAnalytics ? 100 : -200,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(204), // 0.8 opacity
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnalyticRow('Buffer Events', _videoAnalytics['bufferCount']),
            _buildAnalyticRow('Buffer Time',
                '${_videoAnalytics['totalBufferTime'].toStringAsFixed(1)}s'),
            _buildAnalyticRow(
                'Quality Switches', _videoAnalytics['qualitySwitches']),
            _buildAnalyticRow('Errors', _videoAnalytics['errors']),
            if (_controller != null)
              _buildAnalyticRow(
                'Current Time',
                '${_controller!.value.position.inMinutes}:${(_controller!.value.position.inSeconds % 60).toString().padLeft(2, '0')}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('snip-${widget.snip.snipId}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: GestureDetector(
        onTap: _togglePlay,
        onDoubleTapDown: (details) => _handleDoubleTapSeek(details, true),
        onSecondaryTapDown: (details) => _handleDoubleTapSeek(details, false),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            if (_isInitialized && _controller != null)
              VideoPlayer(_controller!)
            else if (!_hasError)
              _buildLoadingThumbnail(),

            // Error overlay
            if (_hasError) _buildErrorOverlay(),

            // Buffering overlay
            if (_isBuffering && !_hasError) _buildBufferingOverlay(),

            // Progress bar at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _isInitialized && !_hasError
                  ? _buildProgressBar()
                  : const SizedBox(),
            ),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(102), // 0.4 opacity
                    ],
                  ),
                ),
              ),
            ),

            // Like animation overlay
            Positioned.fill(
              child: ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.2).animate(
                  CurvedAnimation(
                    parent: _likeAnimation,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white.withAlpha(217), // 0.85 opacity
                    size: 100,
                  ),
                ),
              ),
            ),

            // Network quality indicator
            _buildNetworkQualityIndicator(),

            // Quality selector
            _buildQualitySelector(),

            // Analytics overlay
            _buildAnalyticsOverlay(),

            // Bottom controls and info
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingThumbnail() {
    return widget.snip.video.thumbnail != null
        ? Image.network(
            widget.snip.video.thumbnail!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Colors.black,
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        : const ColoredBox(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator()),
          );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withAlpha(204), // 0.8 opacity
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage(widget.snip.authorProfile.profileImage),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.snip.authorProfile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      SnipParser.getTimeAgo(widget.snip.timestamp),
                      style: TextStyle(
                        color: Colors.white.withAlpha(179), // 0.7 opacity
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          if (widget.snip.description.isNotEmpty)
            Text(
              widget.snip.description,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${widget.snip.likesCount}',
                onTap: () {
                  setState(() => _isLiked = !_isLiked);
                  widget.onLike?.call();
                },
                isActive: _isLiked,
              ),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: '${widget.snip.commentsCount}',
                onTap: widget.onComment,
              ),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: widget.onShare,
              ),
              _buildActionButton(
                icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                label: _isMuted ? 'Unmute' : 'Mute',
                onTap: _toggleMute,
              ),
              _buildActionButton(
                icon: Icons.settings,
                label: 'Quality',
                onTap: _toggleQualitySelector,
              ),
              _buildActionButton(
                icon: Icons.analytics_outlined,
                label: 'Stats',
                onTap: _toggleAnalytics,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.red : Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.red : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchQuality(String quality) async {
    if (!mounted || _controller == null) return;

    try {
      setState(() {
        _isBuffering = true;
        _networkQuality = quality;
      });

      // Pause current playback
      await _controller!.pause();

      // For now, just close the quality selector as we don't have multiple qualities
      setState(() {
        _showQualitySelector = false;
      });

      _updateVideoAnalytics('qualitySwitch');
    } catch (e) {
      debugPrint('Error switching quality: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to switch quality: $e';
      });
    } finally {
      setState(() {
        _isBuffering = false;
      });
    }
  }
}
