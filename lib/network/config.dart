class ApiConfig {
  // Base URLs
  static const String baseUrl = 'https://backend.gigglesdating.com/api';
  static const String functionsBase = '$baseUrl/functions';

  // Endpoints
  static const String requestOtp = '$baseUrl/auth/request-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String database = '$baseUrl/database';
  static const String functions = '$functionsBase'; // Remove trailing slash

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
    return '$functions/$functionName'; // Add function name to path
  }

  // Debug configuration
  static bool get isDebug => true; // Set to false for production
}
