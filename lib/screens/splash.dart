import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'barrel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isVideoInitialized = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _setupFadeAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeVideo();
  }

  void _setupFadeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _fadeController.forward();
  }

  void _initializeVideo() {
    if (_isNavigating) return;

    try {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      _videoController = VideoPlayerController.asset(
        isDarkMode ? 'assets/light/favicon.mp4' : 'assets/dark/favicon.mp4',
      )..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
              _videoController.play();
              _navigateToHome();
            });
          }
        }).catchError((error) {
          debugPrint('Video initialization error: $error');
          if (mounted) {
            setState(() {
              _isVideoInitialized = false;
              _navigateToHome();
            });
          }
        });
    } catch (e) {
      debugPrint('Video controller setup error: $e');
      _navigateToHome();
    }
  }

  Future<void> _navigateToHome() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeTab(),
        ),
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Hero(
            tag: 'app_logo',
            child: SizedBox(
              width: size.width * 0.4,
              height: size.width * 0.4,
              child: _isVideoInitialized
                  ? VideoPlayer(_videoController)
                  : Image.asset(
                      isDarkMode
                          ? 'assets/dark/favicon.png'
                          : 'assets/light/favicon.png',
                      width: size.width * 0.4,
                      height: size.width * 0.4,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
