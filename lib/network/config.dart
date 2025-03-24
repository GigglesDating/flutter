class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // Base URLs
  static const String baseUrl = 'https://backend.gigglesdating.com/api';
  static const String functionsEndpoint =
      '$baseUrl/functions'; // Removed trailing slash
  static const String databaseEndpoint =
      '$baseUrl/database'; // More descriptive name

  // Standard headers for all API requests
  static const Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json', // Simplified Accept header
  };

  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusNotFound = 404;
  static const int statusServerError = 500;

  // Common response keys
  static const String statusKey = 'status';
  static const String messageKey = 'message';
  static const String dataKey = 'data';
  static const String errorKey = 'error';

  // Function names for API calls
  static const String fetchComments = 'fetch_comments';
  static const String getFeed = 'get_feed';
  static const String getSnips = 'get_snips';
  static const String fetchProfile = 'fetch_profile';
}
