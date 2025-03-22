class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://backend.gigglesdating.com/api';
  static const String functions = '$baseUrl/functions';
  static const String auth = '$baseUrl/auth';
  static const String database = '$baseUrl/database';

  // Auth endpoints
  static const String requestOtp = '$baseUrl/auth/request-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Get function endpoint
  static String getFunctionEndpoint(String function) {
    return '$functions/$function';
  }
}
