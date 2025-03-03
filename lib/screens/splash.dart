import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/network/auth_provider.dart';
import 'barrel.dart';
import '../network/auth_provider.dart';

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
    _checkAuthAndNavigate();
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

  Future<void> _checkAuthAndNavigate() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // Initialize auth state from stored preferences
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initializeAuth();

      // Wait for minimum splash duration
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        // User is authenticated, check registration status
        final regProcess = authProvider.regProcess ?? 'new_user';
        _handleNavigation(regProcess);
      } else {
        // Not authenticated, go to login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Authentication check error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _handleNavigation(String regStatus) {
    if (!mounted) return;

    switch (regStatus) {
      case 'new_user':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
        break;

      case 'reg_started':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KycConsentScreen()),
        );
        break;

      case 'aadhar_in_review':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AadharStatusScreen(),
            settings: const RouteSettings(
                arguments: {'status': AadharStatus.inReview}),
          ),
        );
        break;

      case 'aadhar_failed':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AadharStatusScreen(),
            settings:
                const RouteSettings(arguments: {'status': AadharStatus.failed}),
          ),
        );
        break;

      case 'aadhar_verified':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileCreation1()),
        );
        break;

      case 'pc1':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileCreation2()),
        );
        break;

      case 'pc2':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileCreation3()),
        );
        break;

      case 'waitlisted':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WaitlistScreen()),
        );
        break;

      case 'member_approved':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
        );
        break;

      case 'member':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationController()),
        );
        break;

      case 'member_expired':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WaitlistScreen()),
        );
        break;

      case 'member_banned':
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Account Banned'),
              content: const Text(
                  'Sorry, your account has been banned. Please login with a different account or contact support.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        break;

      default:
        // Handle unknown status or errors
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
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
