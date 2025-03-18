import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'network/auth_provider.dart';
import 'screens/barrel.dart';
import 'services/cache_service.dart';

// Placeholder Screen Template
class PlaceholderScreen extends StatelessWidget {
  final String screenName;
  final String message;

  const PlaceholderScreen({
    super.key,
    required this.screenName,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenName),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                screenName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize cache service with retry
    bool cacheInitialized = false;
    int retryCount = 0;
    while (!cacheInitialized && retryCount < 3) {
      try {
        await CacheService.init();
        cacheInitialized = true;
      } catch (e) {
        retryCount++;
        debugPrint('Failed to initialize cache (attempt $retryCount): $e');
        await Future.delayed(Duration(seconds: 1));
      }
    }

    if (!cacheInitialized) {
      debugPrint('Warning: Cache initialization failed after 3 attempts');
    }

    // Add error handling for renderer
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/light/favicon.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text('Loading...'),
            ],
          ),
        ),
      );
    };

    // Set permanent system UI settings
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    // Set initial system UI mode
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [], // Hide both status and navigation bars
    );

    runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ], child: const MyApp()),
    );
  } catch (e) {
    debugPrint('Fatal error during app initialization: $e');
    // Show error screen
    runApp(MaterialApp(
      home: Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to start app',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: $e',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giggles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/waitlist': (context) => const WaitlistScreen(),
        '/navigation': (context) => const NavigationController(),
      },
    );
  }
}
