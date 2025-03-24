class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://backend.gigglesdating.com/api';
  static const String functions = '$baseUrl/functions/';
  static const String database = '$baseUrl/database';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
