import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../network/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

class ThinkProvider {
  final ApiService _apiService = ApiService();
  static final ThinkProvider _instance = ThinkProvider._internal();

  factory ThinkProvider() => _instance;
  ThinkProvider._internal();

  // Helper method for API calls - will be used by all endpoint functions
  @protected // Mark as protected to indicate it's for internal use
  Future<Map<String, dynamic>> _callFunction(
    String functionName,
    Map<String, dynamic> params, {
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    try {
      return await _apiService.makeRequest(
        endpoint: ApiConfig.functions,
        body: {
          'function': functionName,
          ...params,
        },
        cacheDuration: cacheDuration,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('Error in _callFunction for $functionName: $e');
      return {
        'status': 'error',
        'message': 'Failed to execute function: $functionName',
        'error': e.toString(),
      };
    }
  }

///////////////////////////////////////
  ///     FUNCTION DEFINITIONS     ///
  /// ///////////////////////////////

  // Check app version
  Future<Map<String, dynamic>> checkVersion() async {
    try {
      final response = await _callFunction(
        ApiConfig.functionCheckVersion,
        {},
        cacheDuration: ApiConfig.longCache, // Use long cache for version checks
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'latest_version': response['latest_version'],
          'minimum_version': response['minimum_version'],
          'update_mandatory': response['update_mandatory'],
          'update_url': response['update_url'],
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to check version',
        };
      }
    } catch (e) {
      debugPrint('Error in checkVersion: $e');
      return {
        'status': 'error',
        'message': 'Failed to check app version',
        'error': e.toString(),
      };
    }
  }

  // Update user location
  Future<Map<String, dynamic>> updateLocation({
    required String uuid,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _callFunction(
        ApiConfig.functionUpdateLocation,
        {
          'uuid': uuid,
          'latitude': latitude,
          'longitude': longitude,
        },
        cacheDuration:
            ApiConfig.shortCache, // Use short cache for location updates
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
          'data': {
            'location': response['data']['location'],
            'timestamp': response['data']['timestamp'],
          },
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to update location',
        };
      }
    } catch (e) {
      debugPrint('Error in updateLocation: $e');
      return {
        'status': 'error',
        'message': 'Failed to update location',
        'error': e.toString(),
      };
    }
  }

  // User signup
  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String dob,
    required String email,
    required String gender,
    required String city,
    required bool consent,
  }) async {
    try {
      // Get UUID and phone number from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('user_uuid');
      final phoneNumber = prefs.getString('phone_number');

      if (uuid == null || phoneNumber == null) {
        return {
          'status': 'error',
          'message': 'User not authenticated. Please login first.',
        };
      }

      final response = await _callFunction(
        ApiConfig.signup,
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
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
          'reg_process': response['reg_process'],
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to sign up',
        };
      }
    } catch (e) {
      debugPrint('Error in signup: $e');
      return {
        'status': 'error',
        'message': 'Failed to complete signup',
        'error': e.toString(),
      };
    }
  }

  // Check user registration status
  Future<Map<String, dynamic>> checkRegistrationStatus({
    required String uuid,
  }) async {
    try {
      final response = await _callFunction(
        ApiConfig.functionCheckRegistrationStatus,
        {
          'uuid': uuid,
        },
      );

      if (response['status'] == 200) {
        return {
          'status': response['status'],
          'message': response['message'],
          'reg_process': response['reg_process'],
        };
      } else {
        return {
          'status': 'error',
          'message':
              response['message'] ?? 'Failed to check registration status',
        };
      }
    } catch (e) {
      debugPrint('Error in checkRegistrationStatus: $e');
      return {
        'status': 'error',
        'message': 'Failed to check registration status',
        'error': e.toString(),
      };
    }
  }

  // Test AWS connection
  Future<Map<String, dynamic>> testAwsConnection() async {
    try {
      final response = await _callFunction(
        ApiConfig.testAwsConnection,
        {},
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
          'buckets': response['buckets'],
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to test AWS connection',
        };
      }
    } catch (e) {
      debugPrint('Error in testAwsConnection: $e');
      return {
        'status': 'error',
        'message': 'Failed to test AWS connection',
        'error': e.toString(),
      };
    }
  }

  // Submit profile creation step 1
  Future<Map<String, dynamic>> pC1Submit({
    required String uuid,
    required String profileImage,
    required String mandateImage1,
    required String mandateImage2,
    required String genderOrientation,
    required String bio,
    String? optionalImage1,
    String? optionalImage2,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'uuid': uuid,
        'profile_image': profileImage,
        'mandate_image_1': mandateImage1,
        'mandate_image_2': mandateImage2,
        'gender_orientation': genderOrientation,
        'bio': bio,
      };

      // Add optional images if provided
      if (optionalImage1 != null) {
        params['optional_image_1'] = optionalImage1;
      }
      if (optionalImage2 != null) {
        params['optional_image_2'] = optionalImage2;
      }

      final response = await _callFunction(
        ApiConfig.pC1Submit,
        params,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
          'uuid': response['uuid'],
          'reg_status': response['reg_status'],
        };
      } else {
        return {
          'status': 'error',
          'message':
              response['message'] ?? 'Failed to submit profile creation step 1',
        };
      }
    } catch (e) {
      debugPrint('Error in pC1Submit: $e');
      return {
        'status': 'error',
        'message': 'Failed to submit profile creation step 1',
        'error': e.toString(),
      };
    }
  }

  // Submit profile creation step 2
  Future<Map<String, dynamic>> pC2Submit({
    required String uuid,
    required List<String> interests,
    required List<String> languages,
    required List<String> relationshipGoals,
    required List<String> dealBreakers,
    required String aboutMe,
    String? optionalImage3,
    String? optionalImage4,
    String? optionalImage5,
    String? optionalImage6,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'uuid': uuid,
        'interests': interests,
        'languages': languages,
        'relationship_goals': relationshipGoals,
        'deal_breakers': dealBreakers,
        'about_me': aboutMe,
      };

      // Add optional images if provided
      if (optionalImage3 != null) {
        params['optional_image_3'] = optionalImage3;
      }
      if (optionalImage4 != null) {
        params['optional_image_4'] = optionalImage4;
      }
      if (optionalImage5 != null) {
        params['optional_image_5'] = optionalImage5;
      }
      if (optionalImage6 != null) {
        params['optional_image_6'] = optionalImage6;
      }

      final response = await _callFunction(
        ApiConfig.pC2Submit,
        params,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
          'uuid': response['uuid'],
          'reg_status': response['reg_status'],
        };
      } else {
        return {
          'status': 'error',
          'message':
              response['message'] ?? 'Failed to submit profile creation step 2',
        };
      }
    } catch (e) {
      debugPrint('Error in pC2Submit: $e');
      return {
        'status': 'error',
        'message': 'Failed to submit profile creation step 2',
        'error': e.toString(),
      };
    }
  }

  // Submit profile creation step 3
  Future<Map<String, dynamic>> pC3Submit({
    required String uuid,
    required List<String> selectedInterests,
  }) async {
    try {
      final response = await _callFunction(
        ApiConfig.pC3Submit,
        {
          'uuid': uuid,
          'selected_interests': selectedInterests,
        },
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
          'reg_process':
              response['reg_process'], // Will be 'waitlisted' on success
        };
      } else {
        return {
          'status': 'error',
          'message':
              response['message'] ?? 'Failed to submit profile creation step 3',
        };
      }
    } catch (e) {
      debugPrint('Error in pC3Submit: $e');
      return {
        'status': 'error',
        'message': 'Failed to submit profile creation step 3',
        'error': e.toString(),
      };
    }
  }

  // Get available interests
  Future<Map<String, dynamic>> getInterests({
    required String uuid,
  }) async {
    try {
      final response = await _callFunction(
        ApiConfig.getInterests,
        {
          'UUID':
              uuid, // Note: Backend expects 'UUID' (uppercase) as per the request body
        },
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': response[
              'data'], // List of interest objects with id, name, icon_name, and category
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch interests',
        };
      }
    } catch (e) {
      debugPrint('Error in getInterests: $e');
      return {
        'status': 'error',
        'message': 'Failed to fetch interests',
        'error': e.toString(),
      };
    }
  }

  // Add a custom interest
  Future<Map<String, dynamic>> addCustomInterest({
    required String uuid,
    required String interestName,
  }) async {
    try {
      final response = await _callFunction(
        ApiConfig.addCustomInterest,
        {
          'uuid': uuid,
          'interest_name': interestName,
        },
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
          'data': response['data'], // Contains the created interest object
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to add custom interest',
        };
      }
    } catch (e) {
      debugPrint('Error in addCustomInterest: $e');
      return {
        'status': 'error',
        'message': 'Failed to add custom interest',
        'error': e.toString(),
      };
    }
  }

  // Submit Aadhar verification information
  Future<Map<String, dynamic>> submitAadharInfo({
    required String uuid,
    String? aadharImage,
    String? selfieImage,
    String? aadharPdfFile,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'uuid': uuid,
      };

      // Add optional parameters only if they are provided
      if (aadharImage != null) {
        params['AadharImage'] = aadharImage;
      }
      if (selfieImage != null) {
        params['SelfieImage'] = selfieImage;
      }
      if (aadharPdfFile != null) {
        params['Aadhar_pdf_file'] = aadharPdfFile;
      }

      final response = await _callFunction(
        ApiConfig.submitAadharInfo,
        params,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
        };
      } else {
        return {
          'status': 'error',
          'message':
              response['message'] ?? 'Failed to submit Aadhar information',
        };
      }
    } catch (e) {
      debugPrint('Error in submitAadharInfo: $e');
      return {
        'status': 'error',
        'message': 'Failed to submit Aadhar information',
        'error': e.toString(),
      };
    }
  }

  // Submit a support ticket
  Future<Map<String, dynamic>> submitSupportTicket({
    required String uuid,
    required String screenName,
    required String supportText,
    String? image1,
    String? image2,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'uuid': uuid,
        'screen_name': screenName,
        'support_text': supportText,
      };

      // Add optional images if provided
      if (image1 != null) {
        params['image1'] = image1;
      }
      if (image2 != null) {
        params['image2'] = image2;
      }

      final response = await _callFunction(
        ApiConfig.submitSupportTicket,
        params,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
          'ticket_id': response['ticket_id'],
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to submit support ticket',
        };
      }
    } catch (e) {
      debugPrint('Error in submitSupportTicket: $e');
      return {
        'status': 'error',
        'message': 'Failed to submit support ticket',
        'error': e.toString(),
      };
    }
  }

  // Handle user logout
  Future<Map<String, dynamic>> logout({
    required String uuid,
  }) async {
    try {
      final response = await _callFunction(
        ApiConfig.logout,
        {
          'uuid': uuid,
        },
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to logout',
        };
      }
    } catch (e) {
      debugPrint('Error in logout: $e');
      return {
        'status': 'error',
        'message': 'Failed to logout',
        'error': e.toString(),
      };
    }
  }

  // Delete user account and all associated data
  Future<Map<String, dynamic>> deleteAccount({
    required String uuid,
  }) async {
    try {
      final response = await _callFunction(
        ApiConfig.deleteAccount,
        {
          'uuid': uuid,
        },
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'message': response['message'],
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to delete account',
        };
      }
    } catch (e) {
      debugPrint('Error in deleteAccount: $e');
      return {
        'status': 'error',
        'message': 'Failed to delete account',
        'error': e.toString(),
      };
    }
  }

  // Get FAQs
  Future<Map<String, dynamic>> getFaqs() async {
    try {
      final response = await _callFunction(
        ApiConfig.getFaqs,
        {},
        cacheDuration:
            ApiConfig.longCache, // Cache FAQs since they rarely change
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
      debugPrint('Error in getFaqs: $e');
      return {
        'status': 'error',
        'message': 'Failed to fetch FAQs',
        'error': e.toString(),
      };
    }
  }

  // Get events
  Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await _callFunction(
        ApiConfig.getEvents,
        {},
        cacheDuration:
            ApiConfig.mediumCache, // Cache events for a medium duration
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'events':
              response['events'], // List of events with presigned image URLs
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch events',
        };
      }
    } catch (e) {
      debugPrint('Error in getEvents: $e');
      return {
        'status': 'error',
        'message': 'Failed to fetch events',
        'error': e.toString(),
      };
    }
  }

  // Get intro video URL
  Future<Map<String, dynamic>> getIntroVideo() async {
    try {
      final response = await _callFunction(
        ApiConfig.getIntroVideo,
        {},
        cacheDuration:
            ApiConfig.longCache, // Cache URL since video rarely changes
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'intro_video_url': response['data']['intro_video_url'],
          },
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
        'message': 'Failed to fetch intro video',
        'error': e.toString(),
      };
    }
  }

  // Update event like status or check liked events
  Future<Map<String, dynamic>> updateEventLike({
    required String uuid,
    required String action,
    String? eventId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'uuid': uuid,
        'action': action,
      };

      // Add event_id only for like action
      if (action == 'like' && eventId != null) {
        params['event_id'] = eventId;
      }

      final response = await _callFunction(
        ApiConfig.updateEventLike,
        params,
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': response['data'],
        };
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
        'message': 'Failed to update event like',
        'error': e.toString(),
      };
    }
  }

  // Get paginated feed with profile information
  Future<Map<String, dynamic>> getFeed({
    required String uuid,
    int page = 1,
    String? profileId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'uuid': uuid,
        'page': page,
      };

      // Add profile_id if provided
      if (profileId != null) {
        params['profile_id'] = profileId;
      }

      final response = await _callFunction(
        ApiConfig.getFeed,
        params,
        cacheDuration:
            ApiConfig.shortCache, // Short cache since feed updates frequently
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': response[
              'data'], // Contains posts, has_more, next_page, and total_posts
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch feed',
        };
      }
    } catch (e) {
      debugPrint('Error in getFeed: $e');
      return {
        'status': 'error',
        'message': 'Failed to fetch feed',
        'error': e.toString(),
      };
    }
  }

  // Get paginated snips feed with profile information
  Future<Map<String, dynamic>> getSnips({
    required String uuid,
    int page = 1,
    String? profileId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'uuid': uuid,
        'page': page,
      };

      // Add profile_id if provided
      if (profileId != null) {
        params['profile_id'] = profileId;
      }

      final response = await _callFunction(
        ApiConfig.getSnips,
        params,
        cacheDuration: ApiConfig
            .shortCache, // Short cache since snips feed updates frequently
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': response[
              'data'], // Contains snips, has_more, next_page, and total_snips
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch snips',
        };
      }
    } catch (e) {
      debugPrint('Error in getSnips: $e');
      return {
        'status': 'error',
        'message': 'Failed to fetch snips',
        'error': e.toString(),
      };
    }
  }

  // Fetch detailed profile information
  Future<Map<String, dynamic>> fetchProfile({
    required String uuid,
    required String profileId,
  }) async {
    try {
      final response = await _callFunction(
        ApiConfig.fetchProfile,
        {
          'uuid': uuid,
          'profile_id': profileId,
        },
        cacheDuration: ApiConfig
            .mediumCache, // Medium cache since profile data changes occasionally
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': response['data'], // Contains complete profile information
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      debugPrint('Error in fetchProfile: $e');
      return {
        'status': 'error',
        'message': 'Failed to fetch profile',
        'error': e.toString(),
      };
    }
  }

  // Fetch comments for a specific content
  Future<Map<String, dynamic>> fetchComments({
    required String uuid,
    required String contentType,
    required String contentId,
  }) async {
    try {
      // Validate content type
      final validContentTypes = ['post', 'snip', 'story'];
      if (!validContentTypes.contains(contentType)) {
        return {
          'status': 'error',
          'message':
              'Invalid content type. Must be one of: ${validContentTypes.join(", ")}',
        };
      }

      final response = await _callFunction(
        ApiConfig.fetchComments,
        {
          'uuid': uuid,
          'content_type': contentType,
          'content_id': contentId,
        },
        cacheDuration: ApiConfig
            .shortCache, // Short cache since comments update frequently
      );

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': response[
              'data'], // Contains comments array and total_comments count
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to fetch comments',
        };
      }
    } catch (e) {
      debugPrint('Error in fetchComments: $e');
      return {
        'status': 'error',
        'message': 'Failed to fetch comments',
        'error': e.toString(),
      };
    }
  }

  // Clean up resources
  void dispose() {
    _apiService.dispose();
  }
}
