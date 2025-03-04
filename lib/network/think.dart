import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThinkProvider {
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

  // Check member status
  Future<Map<String, dynamic>> checkMemberStatus({
    required String uuid,
  }) async {
    try {
      final response = await _callFunction('check_member_status', {
        'uuid': uuid,
      });

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'member': response['member'] ?? 'no',
            'reg_process': response['reg_process'] ?? 'waitlisted',
            'waitlist_position': response['waitlist_position'],
            'total_waitlist': response['total_waitlist'],
          }
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to check member status',
          'data': {'member': 'no', 'reg_process': 'waitlisted'}
        };
      }
    } catch (e) {
      debugPrint('Error in checkMemberStatus: $e');
      return {
        'status': 'error',
        'message': 'Error checking member status: $e',
        'data': {'member': 'no', 'reg_process': 'waitlisted'}
      };
    }
  }

  // Get override number for app review
  Future<Map<String, dynamic>> getOverrideNumber() async {
    try {
      final response = await _callFunction('get_override_number', {});

      if (response['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'number': response['number'],
          }
        };
      } else {
        return {
          'status': 'error',
          'message': response['message'] ?? 'Failed to get override number',
        };
      }
    } catch (e) {
      debugPrint('Error in getOverrideNumber: $e');
      return {
        'status': 'error',
        'message': 'Error getting override number: $e',
      };
    }
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

  // Generic function caller
  Future<Map<String, dynamic>> _callFunction(
    String function,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.functions),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'function': function,
          ...data,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to call function $function: $e');
    }
  }
}
