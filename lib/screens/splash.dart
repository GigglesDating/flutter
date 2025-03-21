import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/network/auth_provider.dart';
import 'dart:async';
import '../routes/app_router.dart';
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initializeAuth();

      // Minimum splash duration for animation
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      if (authProvider.isAuthenticated && authProvider.uuid != null) {
        debugPrint('User authenticated with UUID: ${authProvider.uuid}');

        // Start member status check in background
        unawaited(_checkMemberStatusInBackground(authProvider,
            authProvider.uuid!, authProvider.regProcess ?? 'new_user'));

        // Navigate immediately based on current reg_process
        _handleNavigation(authProvider.regProcess ?? 'new_user');
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

  Future<void> _checkMemberStatusInBackground(
    AuthProvider authProvider,
    String uuid,
    String currentRegProcess,
  ) async {
    try {
      final thinkProvider = ThinkProvider();
      final response = await thinkProvider.checkMemberStatus(uuid: uuid);

      if (!mounted) return;

      if (response['status'] == 'success' &&
          response['data'] != null &&
          response['data']['reg_process'] != null) {
        final newRegProcess = response['data']['reg_process'];

        // Only update if reg_process has changed
        if (newRegProcess != currentRegProcess) {
          debugPrint(
              'Updating reg_process from $currentRegProcess to $newRegProcess');
          await authProvider.updateRegProcess(newRegProcess);
        }
      }
    } catch (e) {
      debugPrint('Background member status check error: $e');
    }
  }

  void _handleNavigation(String regStatus) {
    if (!mounted) return;

    switch (regStatus.toLowerCase()) {
      case 'member':
        AppRouter.navigateToHome(context);
        break;
      case 'new_user':
        Navigator.of(context).pushReplacementNamed(Routes.login);
        break;
      case 'pending_verification':
        Navigator.of(context).pushReplacementNamed(Routes.waitlist);
        break;
      case 'pending_profile':
        Navigator.of(context).pushReplacementNamed(Routes.waitlist);
        break;
      default:
        AppRouter.navigateToLogin(context);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
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
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
