/// Configuration class for API endpoints, headers, timeouts, and other constants.
/// This class is designed to be a single source of truth for all API-related configurations.
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // Base URLs
  static const String baseUrl = 'https://backend.gigglesdating.com/api';
  static const String functionsEndpoint = '$baseUrl/functions';
  static const String databaseEndpoint = '$baseUrl/database';

  // Standard headers for all API requests
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Connection': 'keep-alive',
  };

  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

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

  // Cache durations
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(minutes: 15);
  static const Duration longCache = Duration(hours: 1);
  static const Duration defaultCache = Duration(minutes: 10);

  // Pagination constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxConcurrentRequests = 4;

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const double retryBackoffMultiplier = 2.0;

  // Error messages
  static const String timeoutError = 'Request timed out';
  static const String networkError = 'Network error occurred';
  static const String serverError = 'Server error occurred';
  static const String unauthorizedError = 'Unauthorized access';
  static const String notFoundError = 'Resource not found';

  // Cache keys
  static const String feedCacheKey = 'feed_cache';
  static const String profileCacheKey = 'profile_cache';
  static const String commentsCacheKey = 'comments_cache';
  static const String snipsCacheKey = 'snips_cache';

  // API version
  static const String apiVersion = 'v1';

  // Endpoint paths
  static const String authPath = '/auth';
  static const String usersPath = '/users';
  static const String postsPath = '/posts';
  static const String commentsPath = '/comments';
  static const String mediaPath = '/media';

  // Query parameters
  static const String pageParam = 'page';
  static const String limitParam = 'limit';
  static const String sortParam = 'sort';
  static const String filterParam = 'filter';

  // Sort options
  static const String sortNewest = 'newest';
  static const String sortPopular = 'popular';
  static const String sortRelevant = 'relevant';

  // Filter options
  static const String filterAll = 'all';
  static const String filterFollowing = 'following';
  static const String filterTrending = 'trending';

  // Media types
  static const String imageType = 'image';
  static const String videoType = 'video';
  static const String audioType = 'audio';

  // File size limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxAudioSize = 10 * 1024 * 1024; // 10MB

  // Supported file types
  static const List<String> supportedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp'
  ];
  static const List<String> supportedVideoTypes = [
    'video/mp4',
    'video/quicktime',
    'video/x-msvideo'
  ];
  static const List<String> supportedAudioTypes = [
    'audio/mpeg',
    'audio/wav',
    'audio/ogg'
  ];

  // Cache control
  static const String cacheControlNoCache = 'no-cache';
  static const String cacheControlMaxAge = 'max-age';
  static const String cacheControlStaleWhileRevalidate =
      'stale-while-revalidate';

  // Authentication
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const Duration tokenExpiry = Duration(hours: 24);
  static const Duration refreshTokenExpiry = Duration(days: 7);

  // Validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const String usernamePattern = r'^[a-zA-Z0-9_]+$';
  static const String emailPattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$';

  // Rate limiting headers
  static const String rateLimitHeader = 'X-RateLimit-Limit';
  static const String rateLimitRemainingHeader = 'X-RateLimit-Remaining';
  static const String rateLimitResetHeader = 'X-RateLimit-Reset';

  // Error response structure
  static const Map<String, dynamic> errorResponseTemplate = {
    'status': 'error',
    'message': '',
    'code': 0,
    'data': null
  };

  // Success response structure
  static const Map<String, dynamic> successResponseTemplate = {
    'status': 'success',
    'message': '',
    'data': null
  };
}
