import 'package:flutter/material.dart';
import 'package:flutter_frontend/screens/waitlist/profileCreationScreens/pc2.dart';
import 'package:flutter_frontend/screens/waitlist/siup1.dart';
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _fadeController.forward();
    _navigateToLogin();
  }

  @override
  void dispose() {
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
          child: const AadharStatusScreen(),
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
            child: Image.asset(
              isDarkMode
                  ? 'assets/light/favicon.png'
                  : 'assets/dark/favicon.png',
              width: size.width * 0.4,
              height: size.width * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
