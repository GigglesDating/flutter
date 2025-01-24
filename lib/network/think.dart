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

  // Initial signup with user details
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
    required String firstName,
    required String lastName,
    required String dob,
    required String email,
    required String gender,
    required String city,
    required bool consent,
  }) async {
    return _callFunction('p_c1_submit', {
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

  // Profile Creation Step 2
  Future<Map<String, dynamic>> pC2Submit({
    required String uuid,
    required String bio,
    required String nickname,
    required String username,
    required List<String> photos,
  }) async {
    return _callFunction('p_c2_submit', {
      'uuid': uuid,
      'bio': bio,
      'nickname': nickname,
      'username': username,
      'photos': photos,
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

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return _callFunction('verify_otp', {
      'phone': phone,
      'otp': otp,
    });
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile({
    required String uuid,
  }) async {
    return _callFunction('get_user_profile', {
      'uuid': uuid,
    });
  }

  // Update User Profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String uuid,
    required Map<String, dynamic> data,
  }) async {
    return _callFunction('update_user_profile', {
      'uuid': uuid,
      'data': data,
    });
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
