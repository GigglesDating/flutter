import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'network/auth_provider.dart';
import 'services/cache_service.dart';
import 'routes/app_router.dart';
import 'routes/route_constants.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';

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

    // Get the application documents directory
    final appDir = await path_provider.getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/cache');

    // Create cache directory if it doesn't exist
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    // Initialize Hive with the cache directory
    await Hive.initFlutter(cacheDir.path);
    debugPrint('Hive initialized successfully');

    // Initialize cache service with proper error handling
    await _initializeCacheService();

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
    // Show a user-friendly error screen instead of crashing
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please restart the app\nError: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Attempt to restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeCacheService() async {
  int retryCount = 0;
  const maxRetries = 3;
  const baseDelay = 500; // milliseconds

  while (retryCount < maxRetries) {
    try {
      debugPrint(
          'Attempting to initialize cache service (attempt ${retryCount + 1})');

      // Initialize cache service
      await CacheService.init();

      // Verify initialization
      final stats = await CacheService.getCacheStats();
      debugPrint('Cache service stats: $stats');

      debugPrint('Cache service initialized successfully');
      return;
    } catch (e) {
      retryCount++;
      debugPrint('Failed to initialize cache (attempt $retryCount): $e');

      if (retryCount < maxRetries) {
        final delay = baseDelay * retryCount;
        debugPrint('Retrying in ${delay}ms...');
        await Future.delayed(Duration(milliseconds: delay));
      } else {
        debugPrint(
            'Warning: Cache initialization failed after $maxRetries attempts');
        // Log the error but don't rethrow - we want the app to continue even if cache fails
      }
    }
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.splash,
    );
  }
}
