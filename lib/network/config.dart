/// Configuration class for API endpoints, headers, timeouts, and other constants.
/// This class is designed to be a single source of truth for all API-related configurations.
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // Base URLs
  static const String baseUrl = 'https://backend.gigglesdating.com/api';

  // Endpoints
  static const String requestOtp = '$baseUrl/request-otp';
  static const String verifyOtp = '$baseUrl/verify-otp';
  static const String database = '$baseUrl/database';
  static const String functions =
      '$baseUrl/functions/'; // Fixed the functions endpoint

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Generate endpoint URL - just return the functions endpoint as all function calls go there
  static String getFunctionEndpoint(String functionName) {
    return functions; // All function calls go to the same endpoint
  }
}
