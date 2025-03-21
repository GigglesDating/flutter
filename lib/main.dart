import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'network/auth_provider.dart';
import 'services/cache_service.dart';
import 'routes/app_router.dart';
import 'routes/route_constants.dart';

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

    // Initialize cache service in background
    unawaited(_initializeCacheService());

    // Set permanent system UI settings
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    // Configure error widget
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

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          // Add other providers here
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    rethrow;
  }
}

Future<void> _initializeCacheService() async {
  int retryCount = 0;
  while (retryCount < 3) {
    try {
      await CacheService.init();
      debugPrint('Cache service initialized successfully');
      return;
    } catch (e) {
      retryCount++;
      debugPrint('Failed to initialize cache (attempt $retryCount): $e');
      if (retryCount < 3) {
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
  }
  debugPrint('Warning: Cache initialization failed after 3 attempts');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giggles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.splash,
    );
  }
}
