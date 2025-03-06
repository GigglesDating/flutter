import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoLoader extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const VideoLoader({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
    this.looping = true,
    this.showControls = true,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<VideoLoader> createState() => _VideoLoaderState();
}

class _VideoLoaderState extends State<VideoLoader> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    debugPrint('Initializing video from URL: ${widget.videoUrl}');

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        if (widget.autoPlay) {
          _controller.play();
        }

        _controller.setLooping(widget.looping);
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing video: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.black12,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 8),
                  Text('Failed to load video'),
                ],
              ),
            ),
          );
    }

    if (!_isInitialized) {
      if (widget.thumbnailUrl != null) {
        return CachedNetworkImage(
          imageUrl: widget.thumbnailUrl!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (context, url) =>
              widget.loadingWidget ??
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) {
            debugPrint('Error loading video thumbnail: $error');
            return widget.errorWidget ??
                const Center(child: CircularProgressIndicator());
          },
        );
      }
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black12,
        child: widget.loadingWidget ??
            const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        if (widget.showControls)
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.white54,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
