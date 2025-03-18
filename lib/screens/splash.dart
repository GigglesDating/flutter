import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/network/auth_provider.dart';
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

  Future<void> _checkAuthAndNavigate() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // Initialize auth state from stored preferences
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initializeAuth();

      debugPrint(
          'Initial reg_process from SharedPreferences: ${authProvider.regProcess}');

      // Wait for minimum splash duration
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        final uuid = authProvider.uuid;
        debugPrint('User UUID: $uuid');

        if (uuid != null) {
          final thinkProvider = ThinkProvider();
          final response = await thinkProvider.checkMemberStatus(uuid: uuid);
          debugPrint('API Response: $response');

          if (response['status'] == 'success' && response['data'] != null) {
            final newRegProcess = response['data']['reg_process'];
            final currentRegProcess = authProvider.regProcess;

            debugPrint('Current reg_process: $currentRegProcess');
            debugPrint('New reg_process from API: $newRegProcess');

            if (newRegProcess != null && newRegProcess != currentRegProcess) {
              debugPrint(
                  'Updating reg_process from $currentRegProcess to $newRegProcess');
              await authProvider.updateRegProcess(newRegProcess);

              // Verify the update
              debugPrint(
                  'Updated reg_process in AuthProvider: ${authProvider.regProcess}');
            }
          } else {
            debugPrint('Error or invalid response from API: $response');
            // Keep existing reg_process if API call fails
            debugPrint(
                'Keeping existing reg_process: ${authProvider.regProcess}');
          }
        }

        // Use the final reg_process for navigation
        final regProcess = authProvider.regProcess ?? 'new_user';
        debugPrint('Final reg_process before navigation: $regProcess');
        _handleNavigation(regProcess);
      } else {
        debugPrint('User not authenticated, navigating to login');
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
              'assets/light/favicon.png',
              width: size.width * 0.4,
              height: size.width * 0.4,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
