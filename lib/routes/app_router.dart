import 'package:flutter/material.dart';
import 'route_constants.dart';
import '../screens/barrel.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const NavigationController(initialTab: 0),
          settings: settings,
        );

      case Routes.swipe:
        return MaterialPageRoute(
          builder: (_) => const NavigationController(initialTab: 1),
          settings: settings,
        );

      case Routes.snips:
        return MaterialPageRoute(
          builder: (_) => const NavigationController(initialTab: 3),
          settings: settings,
        );

      case Routes.profile:
        return MaterialPageRoute(
          builder: (_) => const NavigationController(initialTab: 4),
          settings: settings,
        );

      case Routes.waitlist:
        return MaterialPageRoute(
          builder: (_) => const WaitlistScreen(),
          settings: settings,
        );

      default:
        // Handle unknown routes
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Navigation helper methods
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.home,
      (route) => false,
    );
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.login,
      (route) => false,
    );
  }

  static void navigateToWaitlist(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.waitlist,
      (route) => false,
    );
  }

  static void navigateToTab(BuildContext context, String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (r) => false,
    );
  }

  static void logout(BuildContext context) {
    // Clear any necessary state/storage here
    navigateToLogin(context);
  }

  // Prevent instantiation
  AppRouter._();
}
