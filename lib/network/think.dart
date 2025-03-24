import 'config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import 'dart:async';
import 'dart:math';

class ThinkProvider {
  final ApiService _apiService = ApiService();
  static final ThinkProvider _instance = ThinkProvider._internal();
  static const int _maxRetries = 3;

  factory ThinkProvider() => _instance;

  ThinkProvider._internal() {
    _initializeEndpoints();
  }

  Future<void> _initializeEndpoints() async {
    try {
      final response = await _apiService.makeRequest(
        endpoint: ApiConfig.functionsEndpoint,
        body: {'function': 'initialize'},
        cacheDuration: CacheService.mediumCache,
      );

      if (response['status'] != 'success') {
        debugPrint('API initialization failed: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Failed to initialize API endpoints: $e');
    }
  }

  Future<Map<String, dynamic>> _callFunction(
    String function,
    Map<String, dynamic> params, {
    int retryCount = 0,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    try {
      final requestBody = {'function': function, ...params};

      final response = await _apiService.makeRequest(
        endpoint: ApiConfig.functionsEndpoint,
        body: requestBody,
        cacheDuration: cacheDuration,
        forceRefresh: forceRefresh,
      );

      if (response['status'] == 'success') {
        return response;
      }

      final errorMessage = response['message'] ?? 'API call failed';

      if (retryCount < _maxRetries - 1 &&
          !errorMessage.contains('Invalid JSON') &&
          !errorMessage.contains('API Error 4')) {
        final waitTime = Duration(
          milliseconds: pow(2, retryCount + 1).toInt() * 1000,
        );
        await Future.delayed(waitTime);
        return _callFunction(
          function,
          params,
          retryCount: retryCount + 1,
          cacheDuration: cacheDuration,
          forceRefresh: forceRefresh,
        );
      }

      return {'status': 'error', 'message': errorMessage, 'data': null};
    } catch (e) {
      if (retryCount < _maxRetries - 1) {
        final waitTime = Duration(
          milliseconds: pow(2, retryCount + 1).toInt() * 1000,
        );
        await Future.delayed(waitTime);
        return _callFunction(
          function,
          params,
          retryCount: retryCount + 1,
          cacheDuration: cacheDuration,
          forceRefresh: forceRefresh,
        );
      }

      return {'status': 'error', 'message': e.toString(), 'data': null};
    }
  }

  // Check app version - medium cache
  Future<Map<String, dynamic>> checkVersion() async {
    return _callFunction(
      'check_version',
      {},
      cacheDuration: CacheService.mediumCache,
    );
  }

  // Update user location - no cache
  Future<Map<String, dynamic>> updateLocation({
    required String uuid,
    required double latitude,
    required double longitude,
  }) async {
    return _callFunction(
        'update_location',
        {
          'uuid': uuid,
          'latitude': latitude,
          'longitude': longitude,
        },
        forceRefresh: true);
  }

  // Check registration status - short cache
  Future<Map<String, dynamic>> checkRegistrationStatus({
    required String uuid,
  }) async {
    return _callFunction(
        'check_registration_status',
        {
          'uuid': uuid,
        },
        cacheDuration: CacheService.shortCache);
  }

  // Initial signup - no cache
  Future<Map<String, dynamic>> signup({
    required String uuid,
    required String firstName,
    required String lastName,
    required String dob,
    required String email,
    required String gender,
    required String city,
    required bool consent,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phone_number');

    return _callFunction(
        'signup',
        {
          'uuid': uuid,
          'phone_number': phoneNumber,
          'firstName': firstName,
          'lastName': lastName,
          'dob': dob,
          'email': email,
          'gender': gender,
          'city': city,
          'consent': consent,
        },
        forceRefresh: true);
  }

  // Profile Creation Step 1 - no cache
  Future<Map<String, dynamic>> pC1Submit({
    required String uuid,
    required String profileImage,
    required String bio,
    required String mandateImage1,
    required String mandateImage2,
    required String genderOrientation,
    String? optionalImage1,
    String? optionalImage2,
  }) async {
    return _callFunction(
        'p_c1_submit',
        {
          'uuid': uuid,
          'profile_image': profileImage,
          'bio': bio,
          'mandate_image_1': mandateImage1,
          'mandate_image_2': mandateImage2,
          'gender_orientation': genderOrientation,
          if (optionalImage1 != null) 'optional_image_1': optionalImage1,
          if (optionalImage2 != null) 'optional_image_2': optionalImage2,
        },
        forceRefresh: true);
  }

  // Profile Creation Step 2 - no cache
  Future<Map<String, dynamic>> pC2Submit({
    required String uuid,
    required List<String> genderPreference,
    required Map<String, dynamic> agePreference,
  }) async {
    return _callFunction(
        'p_c2_submit',
        {
          'uuid': uuid,
          'gender_preference': genderPreference,
          'age_preference': agePreference,
        },
        forceRefresh: true);
  }

  // Profile Creation Step 3 - no cache
  Future<Map<String, dynamic>> pC3Submit({
    required String uuid,
    required List<Map<String, dynamic>> selectedInterests,
  }) async {
    return _callFunction(
        'p_c3_submit',
        {
          'uuid': uuid,
          'selected_interests': selectedInterests,
        },
        forceRefresh: true);
  }

  // Get all interests - long cache
  Future<Map<String, dynamic>> getInterests() async {
    return _callFunction(
      'get_interests',
      {},
      cacheDuration: CacheService.longCache,
    );
  }

  // Add custom interest - no cache
  Future<Map<String, dynamic>> addCustomInterest({
    required String uuid,
    required String interestName,
  }) async {
    return _callFunction(
        'add_custom_interest',
        {
          'uuid': uuid,
          'interest_name': interestName,
        },
        forceRefresh: true);
  }

  // Submit Aadhar Information - no cache
  Future<Map<String, dynamic>> submitAadharInfo({
    required String uuid,
    required Map<String, dynamic> kycData,
  }) async {
    return _callFunction(
        'submit_aadhar_info',
        {
          'uuid': uuid,
          ...kycData,
        },
        forceRefresh: true);
  }

  // Submit Support Ticket - no cache
  Future<Map<String, dynamic>> submitSupportTicket({
    required String uuid,
    required String screenName,
    required String supportText,
    String? image1,
    String? image2,
  }) async {
    return _callFunction(
        'submit_support_ticket',
        {
          'uuid': uuid,
          'screen_name': screenName,
          'support_text': supportText,
          if (image1 != null) 'image1': image1,
          if (image2 != null) 'image2': image2,
        },
        forceRefresh: true);
  }

  // Logout - no cache
  Future<Map<String, dynamic>> logout({required String uuid}) async {
    return _callFunction('logout', {'uuid': uuid}, forceRefresh: true);
  }

  // Delete account - no cache
  Future<Map<String, dynamic>> deleteAccount({required String uuid}) async {
    return _callFunction('delete_account', {'uuid': uuid}, forceRefresh: true);
  }

  // Get FAQs - long cache
  Future<Map<String, dynamic>> getFaqs() async {
    return _callFunction('get_faqs', {}, cacheDuration: CacheService.longCache);
  }

  // Check member status - short cache
  Future<Map<String, dynamic>> checkMemberStatus({required String uuid}) async {
    return _callFunction(
        'check_registration_status',
        {
          'uuid': uuid,
        },
        cacheDuration: CacheService.shortCache);
  }

  // Get override number - long cache
  Future<Map<String, dynamic>> getOverrideNumber() async {
    return _callFunction(
      'get_override_number',
      {},
      cacheDuration: CacheService.longCache,
    );
  }

  // Get intro video - medium cache
  Future<Map<String, dynamic>> getIntroVideo() async {
    return _callFunction(
      'get_intro_video',
      {},
      cacheDuration: CacheService.mediumCache,
    );
  }

  // Get events - short cache
  Future<Map<String, dynamic>> getEvents() async {
    return _callFunction(
      'get_events',
      {},
      cacheDuration: CacheService.shortCache,
    );
  }

  // Update event like - no cache
  Future<Map<String, dynamic>> updateEventLike({
    required String uuid,
    String? eventId,
    String? action,
  }) async {
    return _callFunction(
        'update_event_like',
        {
          'uuid': uuid,
          if (eventId != null) 'event_id': eventId,
          'action': action ?? 'check',
        },
        forceRefresh: true);
  }

  // Get feed posts - short cache
  Future<Map<String, dynamic>> getFeed({
    required String uuid,
    int page = 1,
    int pageSize = 10,
    String? profileId,
  }) async {
    final Map<String, dynamic> requestBody = {
      'uuid': uuid,
      'page': page,
      'page_size': pageSize,
    };

    if (profileId != null) {
      requestBody['profile_id'] = profileId;
    }

    return _callFunction(
      'get_feed',
      requestBody,
      cacheDuration: CacheService.shortCache,
    );
  }

  // Get snips/reels - short cache
  Future<Map<String, dynamic>> getSnips({
    required String uuid,
    int page = 1,
    String? profileId,
  }) async {
    final Map<String, dynamic> requestBody = {'uuid': uuid, 'page': page};

    if (profileId != null) {
      requestBody['profile_id'] = profileId;
    }

    return _callFunction(
      'get_snips',
      requestBody,
      cacheDuration: CacheService.shortCache,
    );
  }

  // Fetch profile - short cache
  Future<Map<String, dynamic>> fetchProfile({
    required String uuid,
    required String profileId,
  }) async {
    return _callFunction(
        'fetch_profile',
        {
          'uuid': uuid,
          'profile_id': profileId,
        },
        cacheDuration: CacheService.shortCache);
  }

  // Fetch comments - short cache
  Future<Map<String, dynamic>> fetchComments({
    required String uuid,
    required String contentId,
    required String contentType,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _callFunction(
        'fetch_comments',
        {
          'uuid': uuid,
          'content_id': contentId,
          'content_type': contentType,
          'page': page,
          'page_size': pageSize,
        },
        cacheDuration: CacheService.shortCache);
  }

  // Request OTP - no cache
  Future<Map<String, dynamic>> requestOtp({required String phoneNumber}) async {
    return _callFunction(
        'request_otp',
        {
          'phoneNumber': phoneNumber,
        },
        forceRefresh: true);
  }

  // Verify OTP - no cache
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
    required String requestId,
  }) async {
    return _callFunction(
        'verify_otp',
        {
          'phoneNumber': phoneNumber,
          'otp': otp,
          'requestId': requestId,
        },
        forceRefresh: true);
  }

  // Get user profile - short cache
  Future<Map<String, dynamic>> getUserProfile({required String uuid}) async {
    return _callFunction(
        'get_profile',
        {
          'uuid': uuid,
        },
        cacheDuration: CacheService.shortCache);
  }

  // Update profile - no cache
  Future<Map<String, dynamic>> updateProfile({
    required String uuid,
    required Map<String, dynamic> profileData,
  }) async {
    return _callFunction(
        'update_profile',
        {
          'uuid': uuid,
          ...profileData,
        },
        forceRefresh: true);
  }

  // Batch load initial data - short cache
  Future<Map<String, dynamic>> loadInitialData({required String uuid}) async {
    final List<Map<String, dynamic>> functions = [
      {
        'name': 'check_registration_status',
        'params': {'uuid': uuid},
      },
      {
        'name': 'get_profile',
        'params': {'uuid': uuid},
      },
    ];

    final results = await _apiService.batchRequests(
      requests: functions
          .map((f) => {
                'endpoint': ApiConfig.functionsEndpoint,
                'body': {
                  'function': f['name'] as String,
                  ...(f['params'] as Map<String, dynamic>),
                },
              })
          .toList(),
      cacheDuration: CacheService.shortCache,
    );

    return {
      'status': 'success',
      'data': {'registration_status': results[0], 'profile': results[1]},
    };
  }

  // Clean up resources
  void dispose() {
    _apiService.dispose();
  }
}
