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

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _setupFadeAnimation();
    _navigateToLogin();
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
    try {
      final isDarkMode =
          MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      _videoController = VideoPlayerController.asset(
        isDarkMode ? 'assets/light/favicon.mp4' : 'assets/dark/favicon.mp4',
      )..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
              _videoController.play();
            });
          }
        }).catchError((error) {
          debugPrint('Video initialization error: $error');
          debugPrint('Video path: ${_videoController.dataSource}');
          if (mounted) {
            setState(() {
              _isVideoInitialized = false;
            });
          }
        });
    } catch (e) {
      debugPrint('Video controller setup error: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: const SubscriptionScreen(),
        ),
      ),
    );
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
