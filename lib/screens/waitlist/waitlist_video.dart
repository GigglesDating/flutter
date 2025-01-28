import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../barrel.dart';

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

  // late Future<void> _initializeVideoPlayerFuture;
  bool isPlaying = false;
  bool _isFirstTimeCompleted = false;
  // bool _isButtonVisible = false;
  bool _replay = false;

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

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _exitFullPage();
  }

  @override
  void initState() {
    super.initState();
    _enterFullPage();
    _videoPlayerController =
        VideoPlayerController.asset("assets/video/Intro_video.mp4");
    // _videoPlayerController.setLooping(true);
    _videoPlayerController.initialize().then((_) async {
      setState(() {
        _isInitialized = true;
      });
      _videoPlayerController.play();
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position ==
          _videoPlayerController.value.duration) {
        // If the video is over, mark it as paused
        setState(() {
          if (!_isFirstTimeCompleted) {
            // Show button only after the video completes
            setState(() {
              // _isButtonVisible = true;
              _isFirstTimeCompleted = true;
            });
          }
        });
        setState(() {
          isPlaying = false;
        });
      }
    });
    setState(() {});
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
              child: _isInitialized
                  ? SizedBox(
                      width: _videoPlayerController.value.size.width,
                      height: _videoPlayerController.value.size.height,
                      // aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    )
                  : Center(
                      child: SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            color: const Color.fromARGB(255, 82, 113, 255),
                          ))),
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
          // if (_isButtonVisible)
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
}
