class ApiConfig {
  // Base URLs
  static const String baseUrl = 'https://backend.gigglesdating.com/api';

  // Endpoints
  static const String requestOtp = '$baseUrl/request-otp';
  static const String verifyOtp = '$baseUrl/verify-otp';
  static const String database = '$baseUrl/database';
  static const String functions = '$baseUrl/functions/';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Phone number configuration
  static const String countryCode = '+91';
  static const int phoneNumberLength = 10;
  static const int otpLength = 4; // Changed from 6 to 4 to match login screen

  // Generate endpoint URL
  static String getFunctionEndpoint(String functionName) {
    return functions;
  }
}
