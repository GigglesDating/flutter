import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class AuthProvider {
  // Request OTP
  Future<Map<String, dynamic>> requestOtp({
    required String phoneNumber,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.requestOtp),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'phoneNumber': phoneNumber,
            }),
          )
          .timeout(
            Duration(milliseconds: ApiConfig.connectionTimeout),
          );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'error': 'Failed to connect to server',
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
    required String requestId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.verifyOtp),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'phoneNumber': phoneNumber,
              'otp': otp,
              'requestId': requestId,
            }),
          )
          .timeout(
            Duration(milliseconds: ApiConfig.connectionTimeout),
          );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'error': 'Failed to connect to server',
      };
    }
  }
}
