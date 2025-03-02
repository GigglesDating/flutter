import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../barrel.dart';
import 'dart:async';

class WaitlistVideo extends StatefulWidget {
  final bool? value;
  const WaitlistVideo({
    super.key,
    this.value,
  });

  @override
  State<WaitlistVideo> createState() => _WaitlistVideo();
}

class _WaitlistVideo extends State<WaitlistVideo> {
  late VideoPlayerController _videoPlayerController;
  bool _isInitialized = false;
  bool isPlaying = false;
  bool _isFirstTimeCompleted = false;
  bool _replay = false;
  bool _isError = false;
  String _errorMessage = '';
  Timer? _urlRefreshTimer;

  void _enterFullPage() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky); // Hide system bars
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  // Exit full-Page and restore normal system UI and portrait orientation
  void _exitFullPage() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge); // Restore system bars
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _refreshVideo() async {
    try {
      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.getIntroVideo();

      if (response['status'] == 'success') {
        String videoUrl = response['data']['intro_video_url'];
        final oldController = _videoPlayerController;
        final position = await oldController.position;

        // Setup new controller with fresh URL
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await _videoPlayerController.initialize();
        await _videoPlayerController.seekTo(position ?? Duration.zero);
        if (oldController.value.isPlaying) {
          _videoPlayerController.play();
        }

        // Dispose old controller after new one is ready
        await oldController.dispose();

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error refreshing video: $e');
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.getIntroVideo();

      if (response['status'] == 'success') {
        String videoUrl = response['data']['intro_video_url'];
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));

        await _videoPlayerController.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _videoPlayerController.play();
        }

        _videoPlayerController.addListener(() {
          if (_videoPlayerController.value.position ==
              _videoPlayerController.value.duration) {
            setState(() {
              if (!_isFirstTimeCompleted) {
                _isFirstTimeCompleted = true;
              }
              isPlaying = false;
            });
          }
        });

        // Setup refresh timer for pre-signed URL
        _urlRefreshTimer = Timer.periodic(const Duration(minutes: 50), (_) {
          _refreshVideo();
        });
      } else {
        setState(() {
          _isError = true;
          _errorMessage = response['message'] ?? 'Failed to load video';
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Error loading video: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _enterFullPage();
    _initializeVideo();
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
        isPlaying = false;
      } else {
        _videoPlayerController.play();
        isPlaying = true;
      }
      setState(() {
        _replay = !_replay;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Expanded(
            child: Center(
              child: _isError
                  ? Text(_errorMessage)
                  : _isInitialized
                      ? SizedBox(
                          width: _videoPlayerController.value.size.width,
                          height: _videoPlayerController.value.size.height,
                          child: VideoPlayer(_videoPlayerController),
                        )
                      : const Center(
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 82, 113, 255),
                            ),
                          ),
                        ),
            ),
          ),
          if (!_videoPlayerController.value.isPlaying)
            if (_isInitialized)
              GestureDetector(
                onTap: _togglePlayPause,
                child: Center(
                  child: Icon(
                    Icons.replay,
                    color: const Color.fromARGB(255, 51, 51, 51),
                    size: 100.0,
                  ),
                ),
              ),
          if (_isInitialized)
            Positioned(
                bottom: 0,
                right: 0,
                child: TextButton(
                    onPressed: () {
                      if (widget.value ?? false) {
                        Navigator.of(context).pop();
                      } else {
                        _exitFullPage();
                        _videoPlayerController.dispose();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WaitlistScreen(),
                            ));
                      }
                    },
                    style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(24))),
                    child: Text(
                      'Skip >',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Sukar',
                        height: 1.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    )))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _urlRefreshTimer?.cancel();
    _exitFullPage();
    super.dispose();
  }
}
