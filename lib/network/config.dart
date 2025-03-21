import 'package:flutter/foundation.dart';

class ApiConfig {
  // Debug mode
  static const bool isDebugMode = true; // Set to false for production

  // Base URLs - Use debug URL in debug mode
  static const String productionBaseUrl =
      'https://backend.gigglesdating.com/api';
  static const String debugBaseUrl =
      'http://localhost:8000/api'; // or your actual debug server

  // Active base URL
  static String get baseUrl => isDebugMode ? debugBaseUrl : productionBaseUrl;

  // API paths
  static const String authPath = 'auth';
  static const String functionsPath = 'functions';
  static const String databasePath = 'database';

  // Full endpoint URLs
  static String get functions => '$baseUrl/$functionsPath';
  static String get database => '$baseUrl/$databasePath';
  static String get requestOtp => '$baseUrl/$authPath/request-otp';
  static String get verifyOtp => '$baseUrl/$authPath/verify-otp';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Generate endpoint URL for specific function
  static String getFunctionEndpoint(String functionName) {
    return '$functions/$functionName'.replaceAll('//', '/');
  }

  // Debug helpers
  static void logEndpoint(String endpoint) {
    if (isDebugMode) {
      debugPrint('🔍 Using endpoint: $endpoint');
      debugPrint('🌐 Base URL: $baseUrl');
      debugPrint('🔑 Debug mode: $isDebugMode');
    }
  }
}
