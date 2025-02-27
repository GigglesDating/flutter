import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  VideoPlayerController? _videoController;
  bool _isNavigating = false;
  bool _useImageFallback = false;

  @override
  void initState() {
    super.initState();
    _setupFadeAnimation();
    _initializeVideo();
    _navigateToHome();
  }

  void _setupFadeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _fadeController.forward();
  }

  Future<void> _initializeVideo() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final videoPath =
        isDarkMode ? 'assets/dark/favicon.mp4' : 'assets/light/favicon.mp4';

    try {
      _videoController = VideoPlayerController.asset(videoPath);
      await _videoController!.initialize();
      if (mounted) {
        _videoController!.play();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _useImageFallback = true;
        });
      }
    }
  }

  Future<void> _navigateToHome() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      // Always navigate to login first unless user is already authenticated
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Hero(
            tag: 'app_logo',
            child: _useImageFallback ||
                    _videoController == null ||
                    !_videoController!.value.isInitialized
                ? Image.asset(
                    isDarkMode
                        ? 'assets/dark/favicon.png'
                        : 'assets/light/favicon.png',
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                  )
                : SizedBox(
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    child: VideoPlayer(_videoController!),
                  ),
          ),
        ),
      ),
    );
  }
}
