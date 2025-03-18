import 'config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ThinkProvider {
  final ApiService _apiService = ApiService();
  static final ThinkProvider _instance = ThinkProvider._internal();

  factory ThinkProvider() => _instance;
  ThinkProvider._internal();

  // Check app version
  Future<Map<String, dynamic>> checkVersion() async {
    return _callFunction('check_version', {});
  }

  // Update user location
  Future<Map<String, dynamic>> updateLocation({
    required String uuid,
    required double latitude,
    required double longitude,
  }) async {
    return _callFunction('update_location', {
      'uuid': uuid,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // Check registration status
  Future<Map<String, dynamic>> checkRegistrationStatus({
    required String uuid,
  }) async {
    return _callFunction('check_registration_status', {
      'uuid': uuid,
    });
  }

  // Initial signup
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
    // Get phone number from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString(
        'phone_number'); // We need to store this during OTP verification

    try {
      final response = await _callFunction('signup', {
        'uuid': uuid,
        'phone_number': phoneNumber, // Add this
        'firstName': firstName,
        'lastName': lastName,
        'dob': dob,
        'email': email,
        'gender': gender,
        'city': city,
        'consent': consent,
      });
      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error during signup: $e',
      };
    }
  }

  // Profile Creation Step 1
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
    return _callFunction('p_c1_submit', {
      'uuid': uuid,
      'profile_image': profileImage,
      'bio': bio,
      'mandate_image_1': mandateImage1,
      'mandate_image_2': mandateImage2,
      'gender_orientation': genderOrientation,
      if (optionalImage1 != null) 'optional_image_1': optionalImage1,
      if (optionalImage2 != null) 'optional_image_2': optionalImage2,
    });
  }

  // Profile Creation Step 2
  Future<Map<String, dynamic>> pC2Submit({
    required String uuid,
    required List<String>
        genderPreference, // Can be ['men', 'women', 'non-binary', 'everyone']
    required Map<String, dynamic> agePreference,
  }) async {
    return _callFunction('p_c2_submit', {
      'uuid': uuid,
      'gender_preference': genderPreference,
      'age_preference': agePreference,
    });
  }

  // Profile Creation Step 3
  Future<Map<String, dynamic>> pC3Submit({
    required String uuid,
    required List<Map<String, dynamic>> selectedInterests,
  }) async {
    return _callFunction('p_c3_submit', {
      'uuid': uuid,
      'selected_interests': selectedInterests,
    });
  }

  // Get all interests from D1BackendDb
  Future<Map<String, dynamic>> getInterests() async {
    return _callFunction('get_interests', {});
  }

  // Add a custom interest
  Future<Map<String, dynamic>> addCustomInterest({
    required String uuid,
    required String interestName,
  }) async {
    return _callFunction('add_custom_interest', {
      'uuid': uuid,
      'interest_name': interestName,
    });
  }

  // Submit Aadhar Information
  Future<Map<String, dynamic>> submitAadharInfo({
    required String uuid,
    required Map<String, dynamic>
        kycData, // The complete JSON data from KYC service
  }) async {
    return _callFunction('submit_aadhar_info', {
      'uuid': uuid,
      ...kycData, // Spread the KYC data into the request
    });
  }

  // Submit Support Ticket
  Future<Map<String, dynamic>> submitSupportTicket({
    required String uuid,
    required String screenName,
    required String supportText,
    String? image1, // base64 encoded image
    String? image2, // base64 encoded image
  }) async {
    return _callFunction('submit_support_ticket', {
      'uuid': uuid,
      'screen_name': screenName,
      'support_text': supportText,
      if (image1 != null) 'image1': image1,
      if (image2 != null) 'image2': image2,
    });
  }

  // In ThinkProvider class
  Future<Map<String, dynamic>> logout({
    required String uuid,
  }) async {
    return _callFunction('logout', {
      'uuid': uuid,
    });
  }

  // In ThinkProvider class
  Future<Map<String, dynamic>> deleteAccount({
    required String uuid,
  }) async {
    return _callFunction('delete_account', {
      'uuid': uuid,
    });
  }

  // Function to fetch Faqs
  Future<Map<String, dynamic>> getFaqs() async {
    try {
      final response = await _callFunction('get_faqs', {});

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

  // Check member status with caching
  Future<Map<String, dynamic>> checkMemberStatus({
    required String uuid,
  }) async {
    return await _callFunction(
      'check_registration_status',
      {'uuid': uuid},
      cacheDuration: const Duration(minutes: 5),
    );
  }

  // Get override number with longer cache
  Future<Map<String, dynamic>> getOverrideNumber() async {
    return await _callFunction(
      'get_override_number',
      {},
      cacheDuration: const Duration(days: 1),
    );
  }

  // Get intro video
  Future<Map<String, dynamic>> getIntroVideo() async {
    try {
      final response = await _callFunction('get_intro_video', {});

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'intro_video_url': response['data']
                ['intro_video_url'] // This is now a pre-signed URL
          }
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

  // Get events
  Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await _callFunction('get_events', {});

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

  // Update or check event likes
  Future<Map<String, dynamic>> updateEventLike({
    required String uuid,
    String? eventId,
    String? action, // only 'like' or 'check' now
  }) async {
    try {
      final response = await _callFunction('update_event_like', {
        'uuid': uuid,
        if (eventId != null) 'event_id': eventId,
        'action': action ?? 'check', // default to 'check' if no action provided
      });

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

  // Get feed posts with pagination
  Future<Map<String, dynamic>> getFeed({
    required String uuid,
    int page = 1,
    String? profileId, // New optional parameter
  }) async {
    try {
      // Create request body with optional profile_id
      final Map<String, dynamic> requestBody = {
        'uuid': uuid,
        'page': page,
      };

      // Add profile_id to request only if it's provided
      if (profileId != null) {
        requestBody['profile_id'] = profileId;
      }

      final response = await _callFunction('get_feed', requestBody);

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

// Get snips/reels with pagination
  Future<Map<String, dynamic>> getSnips({
    required String uuid,
    int page = 1,
    String? profileId, // New optional parameter
  }) async {
    try {
      // Create request body with optional profile_id
      final Map<String, dynamic> requestBody = {
        'uuid': uuid,
        'page': page,
        'profile_id': profileId,
      };

      // Add profile_id to request only if it's provided
      if (profileId != null) {
        requestBody['profile_id'] = profileId;
      }

      final response = await _callFunction('get_snips', requestBody);

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

  // Fetch profile information
  Future<Map<String, dynamic>> fetchProfile({
    required String uuid,
    required String profileId,
  }) async {
    try {
      final response = await _callFunction('fetch_profile', {
        'uuid': uuid,
        'profile_id': profileId,
      });

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

  // Fetch comments for a specific content (post/snip/story)
  Future<Map<String, dynamic>> fetchComments({
    required String uuid,
    required String contentType,
    required String contentId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _callFunction('fetch_comments', {
        'uuid': uuid,
        'content_type': contentType,
        'content_id': contentId,
        'page': page,
        'page_size': pageSize,
      });

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'comments':
                List<Map<String, dynamic>>.from(response['data']['comments']),
            'total_comments': response['data']['total_comments'],
            'has_more': response['data']['has_more'] ?? false,
            'next_page': response['data']['next_page'],
          }
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch comments',
          'data': {
            'comments': [],
            'total_comments': 0,
            'has_more': false,
            'next_page': null,
          }
        };
      }
    } catch (e) {
      debugPrint('Error in fetchComments: $e');
      return {
        'status': 'error',
        'message': 'Error fetching comments: $e',
        'data': {
          'comments': [],
          'total_comments': 0,
          'has_more': false,
          'next_page': null,
        }
      };
    }
  }

  // Helper method for API calls
  Future<Map<String, dynamic>> _callFunction(
    String functionName,
    Map<String, dynamic> params, {
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    try {
      final endpoint = ApiConfig.getFunctionEndpoint(functionName);
      debugPrint('Calling function $functionName at $endpoint');

      final response = await _apiService.makeRequest(
        endpoint: endpoint,
        body: params,
        cacheDuration: cacheDuration,
        forceRefresh: forceRefresh,
      );

      if (response['status'] == null) {
        throw Exception('Invalid response format');
      }

      return response;
    } catch (e) {
      debugPrint('Error calling function $functionName: $e');
      return {
        'status': 'error',
        'message': 'Failed to connect to server',
      };
    }
  }

  // Batch multiple function calls
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

  // Request OTP without caching
  Future<Map<String, dynamic>> requestOtp({
    required String phoneNumber,
  }) async {
    return await _callFunction(
      'request_otp',
      {'phoneNumber': phoneNumber},
      forceRefresh: true, // Never cache OTP requests
    );
  }

  // Verify OTP without caching
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
    required String requestId,
  }) async {
    return await _callFunction(
      'verify_otp',
      {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'requestId': requestId,
      },
      forceRefresh: true, // Never cache OTP verification
    );
  }

  // Get user profile with short cache
  Future<Map<String, dynamic>> getUserProfile({
    required String uuid,
  }) async {
    return await _callFunction(
      'get_profile',
      {'uuid': uuid},
      cacheDuration: const Duration(minutes: 15),
    );
  }

  // Update profile without cache
  Future<Map<String, dynamic>> updateProfile({
    required String uuid,
    required Map<String, dynamic> profileData,
  }) async {
    return await _callFunction(
      'update_profile',
      {
        'uuid': uuid,
        ...profileData,
      },
      forceRefresh: true,
    );
  }

  // Batch load initial data
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
      // Add other initial data calls here
    ];

    final results = await _batchFunctions(
      functions,
      cacheDuration: const Duration(minutes: 5),
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
