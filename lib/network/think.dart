import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

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
    return _callFunction('signup', {
      'uuid': uuid,
      'first_name': firstName,
      'last_name': lastName,
      'dob': dob,
      'email': email,
      'gender': gender,
      'city': city,
      'consent': consent,
    });
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
