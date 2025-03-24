import 'config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'dart:math';

class ThinkProvider {
  final ApiService _apiService = ApiService();
  static final ThinkProvider _instance = ThinkProvider._internal();
  static const int _maxRetries = 3;

  // Cache durations for different types of data
  static const Duration _shortCache = Duration(minutes: 5);
  static const Duration _mediumCache = Duration(hours: 1);
  static const Duration _longCache = Duration(days: 1);

  factory ThinkProvider() => _instance;

  ThinkProvider._internal() {
    _initializeEndpoints();
  }

  Future<void> _initializeEndpoints() async {
    try {
      debugPrint('🔄 Initializing API endpoints...');
      final response = await _apiService.makeRequest(
        endpoint: ApiConfig.functions,
        body: {
          'function': 'initialize',
        },
        cacheDuration: _mediumCache,
      );

      if (response['status'] == 'success') {
        debugPrint('✅ API Endpoints initialized successfully');
      } else {
        debugPrint('⚠️ API initialization failed: ${response['message']}');
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize API endpoints: $e');
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
      debugPrint('📡 Calling API function: $function');
      debugPrint('📦 Parameters: $params');

      final requestBody = {
        'function': function,
        ...params,
      };
      debugPrint('📦 Request body: $requestBody');

      final response = await _apiService.makeRequest(
        endpoint: ApiConfig.functions,
        body: requestBody,
        cacheDuration: cacheDuration,
        forceRefresh: forceRefresh,
      );

      if (response['status'] == 'success') {
        debugPrint('✅ API call successful');
        return response;
      } else {
        final errorMessage = response['message'] ?? 'API call failed';
        debugPrint('⚠️ API call failed: $errorMessage');

        // Check if we should retry based on the error
        if (retryCount < _maxRetries - 1 &&
            !errorMessage.contains('Invalid JSON') &&
            !errorMessage.contains('API Error 4')) {
          // Don't retry 4xx errors
          final waitTime =
              Duration(milliseconds: pow(2, retryCount + 1).toInt() * 1000);
          debugPrint('⏳ Retrying in ${waitTime.inSeconds} seconds...');
          await Future.delayed(waitTime);
          return _callFunction(
            function,
            params,
            retryCount: retryCount + 1,
            cacheDuration: cacheDuration,
            forceRefresh: forceRefresh,
          );
        }

        return {
          'status': 'error',
          'message': errorMessage,
          'error': response['error'],
        };
      }
    } catch (e) {
      debugPrint('❌ API attempt ${retryCount + 1} failed for $function: $e');

      if (retryCount < _maxRetries - 1) {
        final waitTime =
            Duration(milliseconds: pow(2, retryCount + 1).toInt() * 1000);
        debugPrint('⏳ Retrying in ${waitTime.inSeconds} seconds...');
        await Future.delayed(waitTime);
        return _callFunction(
          function,
          params,
          retryCount: retryCount + 1,
          cacheDuration: cacheDuration,
          forceRefresh: forceRefresh,
        );
      }

      return {
        'status': 'error',
        'message': e.toString(),
        'error': e.toString(),
      };
    }
  }

  // Check app version - medium cache
  Future<Map<String, dynamic>> checkVersion() async {
    return _callFunction(
      'check_version',
      {},
      cacheDuration: _mediumCache,
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
      forceRefresh: true,
    );
  }

  // Check registration status - short cache
  Future<Map<String, dynamic>> checkRegistrationStatus({
    required String uuid,
  }) async {
    try {
      final response = await _callFunction(
        'check_registration_status',
        {'uuid': uuid},
        cacheDuration: _shortCache,
      );

      if (response['status'] == 'success' && response['reg_status'] != null) {
        return response;
      }

      if (response['status'] != 'success') {
        debugPrint('Error response from API: $response');
      }

      return {
        'status': 'error',
        'message': response['message'] ?? 'Invalid response format',
      };
    } catch (e) {
      debugPrint('Error in checkRegistrationStatus: $e');
      return {
        'status': 'error',
        'message': 'Failed to check registration status',
      };
    }
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
      forceRefresh: true,
    );
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
      forceRefresh: true,
    );
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
      forceRefresh: true,
    );
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
      forceRefresh: true,
    );
  }

  // Get all interests - long cache
  Future<Map<String, dynamic>> getInterests() async {
    return _callFunction(
      'get_interests',
      {},
      cacheDuration: _longCache,
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
      forceRefresh: true,
    );
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
      forceRefresh: true,
    );
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
      forceRefresh: true,
    );
  }

  // Logout - no cache
  Future<Map<String, dynamic>> logout({
    required String uuid,
  }) async {
    return _callFunction(
      'logout',
      {'uuid': uuid},
      forceRefresh: true,
    );
  }

  // Delete account - no cache
  Future<Map<String, dynamic>> deleteAccount({
    required String uuid,
  }) async {
    return _callFunction(
      'delete_account',
      {'uuid': uuid},
      forceRefresh: true,
    );
  }

  // Get FAQs - long cache
  Future<Map<String, dynamic>> getFaqs() async {
    try {
      final response = await _callFunction(
        'get_faqs',
        {},
        cacheDuration: _longCache,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'faqs': response['faqs'],
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch FAQs',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error fetching FAQs: $e',
      };
    }
  }

  // Check member status - short cache
  Future<Map<String, dynamic>> checkMemberStatus({
    required String uuid,
  }) async {
    return _callFunction(
      'check_registration_status',
      {'uuid': uuid},
      cacheDuration: _shortCache,
    );
  }

  // Get override number - long cache
  Future<Map<String, dynamic>> getOverrideNumber() async {
    return _callFunction(
      'get_override_number',
      {},
      cacheDuration: _longCache,
    );
  }

  // Get intro video - medium cache
  Future<Map<String, dynamic>> getIntroVideo() async {
    try {
      final response = await _callFunction(
        'get_intro_video',
        {},
        cacheDuration: _mediumCache,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {'intro_video_url': response['data']['intro_video_url']}
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch intro video',
        };
      }
    } catch (e) {
      debugPrint('Error in getIntroVideo: $e');
      return {
        'status': 'error',
        'message': 'Error fetching intro video: $e',
      };
    }
  }

  // Get events - short cache
  Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await _callFunction(
        'get_events',
        {},
        cacheDuration: _shortCache,
      );

      if (response['status'] == 'success') {
        return {'status': 'success', 'data': response['events']};
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch events',
          'data': []
        };
      }
    } catch (e) {
      debugPrint('Error in getEvents: $e');
      return {
        'status': 'error',
        'message': 'Error fetching events: $e',
        'data': []
      };
    }
  }

  // Update event like - no cache
  Future<Map<String, dynamic>> updateEventLike({
    required String uuid,
    String? eventId,
    String? action,
  }) async {
    try {
      final response = await _callFunction(
        'update_event_like',
        {
          'uuid': uuid,
          if (eventId != null) 'event_id': eventId,
          'action': action ?? 'check',
        },
        forceRefresh: true,
      );

      if (response['status'] == 'success') {
        if (action == 'check') {
          return {
            'status': 'success',
            'data': {
              'liked_events':
                  List<String>.from(response['data']['liked_events']),
            }
          };
        } else {
          return {
            'status': 'success',
            'data': {
              'event_id': response['data']['event_id'],
              'likes_count': response['data']['likes_count'],
              'liked_events':
                  List<String>.from(response['data']['liked_events']),
              'is_liked': response['data']['is_liked'],
            }
          };
        }
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to update event like',
        };
      }
    } catch (e) {
      debugPrint('Error in updateEventLike: $e');
      return {
        'status': 'error',
        'message': 'Error updating event like: $e',
      };
    }
  }

  // Get feed posts - short cache
  Future<Map<String, dynamic>> getFeed({
    required String uuid,
    int page = 1,
    int pageSize = 10,
    String? profileId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'uuid': uuid,
        'page': page,
        'page_size': pageSize,
      };

      if (profileId != null) {
        requestBody['profile_id'] = profileId;
      }

      debugPrint('Calling getFeed with params: $requestBody');
      final response = await _callFunction(
        'get_feed',
        requestBody,
        cacheDuration: _shortCache,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'posts': List<Map<String, dynamic>>.from(response['data']['posts']),
            'has_more': response['data']['has_more'],
            'next_page': response['data']['next_page'],
            'total_posts': response['data']['total_posts'],
          }
        };
      } else {
        debugPrint('Error response from getFeed: $response');
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch feed',
          'data': {
            'posts': [],
            'has_more': false,
            'next_page': null,
            'total_posts': 0,
          }
        };
      }
    } catch (e) {
      debugPrint('Error in getFeed: $e');
      return {
        'status': 'error',
        'message': 'Error fetching feed: $e',
        'data': {
          'posts': [],
          'has_more': false,
          'next_page': null,
          'total_posts': 0,
        }
      };
    }
  }

  // Get snips/reels - short cache
  Future<Map<String, dynamic>> getSnips({
    required String uuid,
    int page = 1,
    String? profileId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'uuid': uuid,
        'page': page,
      };

      if (profileId != null) {
        requestBody['profile_id'] = profileId;
      }

      final response = await _callFunction(
        'get_snips',
        requestBody,
        cacheDuration: _shortCache,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'snips': List<Map<String, dynamic>>.from(response['data']['snips']),
            'has_more': response['data']['has_more'],
            'next_page': response['data']['next_page'],
            'total_snips': response['data']['total_snips'],
          }
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch snips',
          'data': {
            'snips': [],
            'has_more': false,
            'next_page': null,
            'total_snips': 0,
          }
        };
      }
    } catch (e) {
      debugPrint('Error in getSnips: $e');
      return {
        'status': 'error',
        'message': 'Error fetching snips: $e',
        'data': {
          'snips': [],
          'has_more': false,
          'next_page': null,
          'total_snips': 0,
        }
      };
    }
  }

  // Fetch profile - short cache
  Future<Map<String, dynamic>> fetchProfile({
    required String uuid,
    required String profileId,
  }) async {
    try {
      final response = await _callFunction(
        'fetch_profile',
        {
          'uuid': uuid,
          'profile_id': profileId,
        },
        cacheDuration: _shortCache,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'profile': Map<String, dynamic>.from(response['data']['profile']),
            'posts_count': response['data']['posts_count'],
            'snips_count': response['data']['snips_count'],
          }
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch profile',
          'data': {
            'profile': {},
            'posts_count': 0,
            'snips_count': 0,
          }
        };
      }
    } catch (e) {
      debugPrint('Error in fetchProfile: $e');
      return {
        'status': 'error',
        'message': 'Error fetching profile: $e',
        'data': {
          'profile': {},
          'posts_count': 0,
          'snips_count': 0,
        }
      };
    }
  }

  // Fetch comments - short cache
  Future<Map<String, dynamic>> fetchComments({
    required String uuid,
    required String contentId,
    required String contentType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return await _callFunction(
        'fetch_comments',
        {
          'uuid': uuid,
          'content_id': contentId,
          'content_type': contentType,
          'page': page,
          'page_size': pageSize,
        },
        cacheDuration: _shortCache,
      );
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      return {
        'status': 'error',
        'message': 'Failed to load comments',
        'error': e.toString(),
      };
    }
  }

  // Batch multiple function calls with caching
  Future<List<Map<String, dynamic>>> _batchFunctions(
    List<Map<String, dynamic>> functions, {
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final requests = functions
        .map((function) => {
              'endpoint': '${ApiConfig.functions}${function['name']}/',
              'body': function['params'],
            })
        .toList();

    return await _apiService.batchRequests(
      requests: requests,
      cacheDuration: cacheDuration,
      forceRefresh: forceRefresh,
    );
  }

  // Request OTP - no cache
  Future<Map<String, dynamic>> requestOtp({
    required String phoneNumber,
  }) async {
    return _callFunction(
      'request_otp',
      {'phoneNumber': phoneNumber},
      forceRefresh: true,
    );
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
      forceRefresh: true,
    );
  }

  // Get user profile - short cache
  Future<Map<String, dynamic>> getUserProfile({
    required String uuid,
  }) async {
    return _callFunction(
      'get_profile',
      {'uuid': uuid},
      cacheDuration: _shortCache,
    );
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
      forceRefresh: true,
    );
  }

  // Batch load initial data - short cache
  Future<Map<String, dynamic>> loadInitialData({
    required String uuid,
  }) async {
    final functions = [
      {
        'name': 'check_registration_status',
        'params': {'uuid': uuid},
      },
      {
        'name': 'get_profile',
        'params': {'uuid': uuid},
      },
    ];

    final results = await _batchFunctions(
      functions,
      cacheDuration: _shortCache,
    );

    return {
      'status': 'success',
      'registration_status': results[0],
      'profile': results[1],
    };
  }

  // Clean up resources
  void dispose() {
    _apiService.dispose();
  }
}
