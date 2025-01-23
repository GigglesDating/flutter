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

  // Signup user
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
