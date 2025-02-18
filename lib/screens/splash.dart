import 'package:flutter/material.dart';
import 'barrel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _setupFadeAnimation();
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

  Future<void> _navigateToHome() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ProfileCreation3(),
        ),
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeTab(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
            child: Image.asset(
              isDarkMode
                  ? 'assets/dark/favicon.png'
                  : 'assets/light/favicon.png',
              width: size.width * 0.4,
              height: size.width * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
