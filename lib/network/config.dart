class ApiConfig {
  // Base URLs
  static const String baseUrl = 'https://backend.gigglesdating.com/api';

  // Endpoints
  static const String requestOtp = '$baseUrl/request-otp/';
  static const String verifyOtp = '$baseUrl/verify-otp/';
  static const String database = '$baseUrl/database/';
  static const String functions = '$baseUrl/functions/';

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
