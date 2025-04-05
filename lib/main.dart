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

    // Initialize background isolate messenger with root isolate token
    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      debugPrint('BackgroundIsolateBinaryMessenger initialized in main');
    } else {
      debugPrint('Warning: RootIsolateToken is null in main');
    }

    // Wait a moment to ensure the messenger is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

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

    // Initialize cache service after messenger is ready
    await _initializeCacheService();

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
  const maxRetries = 3;
  const baseDelay = Duration(milliseconds: 500);

  while (retryCount < maxRetries) {
    try {
      debugPrint(
          'Initializing CacheService (attempt ${retryCount + 1}/$maxRetries)');
      await CacheService.init();
      debugPrint('CacheService initialized successfully');
      return;
    } catch (e) {
      retryCount++;
      debugPrint('Failed to initialize CacheService (attempt $retryCount): $e');

      if (retryCount < maxRetries) {
        // Exponential backoff for retries
        final delay = baseDelay * (1 << (retryCount - 1));
        debugPrint('Retrying in ${delay.inMilliseconds}ms...');
        await Future.delayed(delay);
      } else {
        debugPrint(
            'CacheService initialization failed after $maxRetries attempts');
        // Don't rethrow, let the app continue with limited caching
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
