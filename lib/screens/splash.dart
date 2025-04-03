import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/network/auth_provider.dart';
import 'dart:async';
import '../routes/route_constants.dart';
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
  bool _isStatusCheckComplete = false;
  Timer? _statusCheckTimeout;
  // static const int _maxStatusCheckAttempts = 3;

  @override
  void initState() {
    super.initState();
    _setupFadeAnimation();
    // Delay auth check until animation starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
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
      debugPrint('Starting auth check in splash screen...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initializeAuth();

      if (!mounted) return;

      debugPrint('Auth check results:');
      debugPrint('Is Authenticated: ${authProvider.isAuthenticated}');
      debugPrint('UUID: ${authProvider.uuid}');

      if (authProvider.isAuthenticated && authProvider.uuid != null) {
        debugPrint('User authenticated with UUID: ${authProvider.uuid}');
        await _checkMemberStatus(authProvider.uuid!);
      } else {
        debugPrint('User not authenticated, navigating to login');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      }
    } catch (e) {
      debugPrint('Authentication check error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    }
  }

  Future<void> _checkMemberStatus(String uuid) async {
    if (_isStatusCheckComplete) return;

    try {
      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.checkRegistrationStatus(uuid: uuid);
      debugPrint(
          'SplashScreen._checkMemberStatus received response: $response');

      if (!mounted) return;

      if (response['status'] == 200 && response['reg_process'] != null) {
        final regStatus = response['reg_process'];
        debugPrint('Registration status: $regStatus');

        setState(() {
          _isStatusCheckComplete = true;
        });

        if (mounted) {
          _handleNavigation(regStatus);
        }
      } else {
        // If we don't get a valid response, try one more time
        await Future.delayed(const Duration(seconds: 1));
        final retryResponse =
            await thinkProvider.checkRegistrationStatus(uuid: uuid);

        if (!mounted) return;

        if (retryResponse['status'] == 200 &&
            retryResponse['reg_process'] != null) {
          final regStatus = retryResponse['reg_process'];
          debugPrint('Registration status (retry): $regStatus');

          setState(() {
            _isStatusCheckComplete = true;
          });

          if (mounted) {
            _handleNavigation(regStatus);
          }
        } else {
          // If both attempts fail, navigate to login
          debugPrint('Failed to get registration status, navigating to login');
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        }
      }
    } catch (e) {
      debugPrint('Status check error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    }
  }

  void _handleNavigation(String regStatus) {
    if (!mounted) return;

    debugPrint('Navigating based on registration status: $regStatus');

    switch (regStatus.toLowerCase()) {
      case 'member':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const NavigationController(initialTab: 0),
          ),
          (route) => false,
        );
        break;
      case 'new_user':
        Navigator.of(context).pushReplacementNamed(Routes.login);
        break;
      case 'pending_verification':
      case 'pending_profile':
        Navigator.of(context).pushReplacementNamed(Routes.waitlist);
        break;
      default:
        Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _statusCheckTimeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                isDarkMode
                    ? 'assets/dark/favicon.png'
                    : 'assets/light/favicon.png',
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              const SizedBox(height: 24),
              if (!_isStatusCheckComplete)
                const CircularProgressIndicator()
              else
                Icon(
                  Icons.check_circle,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
