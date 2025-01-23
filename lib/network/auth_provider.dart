import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'config.dart';

class AuthProvider extends ChangeNotifier {
  String? _requestId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get requestId => _requestId;

  // Request OTP
  Future<Map<String, dynamic>> requestOtp({
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http
          .post(
            Uri.parse(ApiConfig.requestOtp),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'phoneNumber': '+91$phoneNumber',
            }),
          )
          .timeout(
            Duration(milliseconds: ApiConfig.connectionTimeout),
          );

      final decodedResponse = jsonDecode(response.body);

      // Store requestId if available
      if (decodedResponse['requestId'] != null) {
        _requestId = decodedResponse['requestId'];
        decodedResponse['status'] = true;
      }

      _isLoading = false;
      notifyListeners();
      return decodedResponse;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'status': false,
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
      _isLoading = true;
      notifyListeners();

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

      if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final decodedResponse = jsonDecode(response.body);

      // If verification successful, store UUID in SharedPreferences
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodedResponse['uuid'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_uuid', decodedResponse['uuid']);

          // Also store registration status if needed
          if (decodedResponse['reg_process'] != null) {
            await prefs.setString(
                'reg_process', decodedResponse['reg_process']);
          }
        }
        decodedResponse['status'] = true;
      }

      _isLoading = false;
      notifyListeners();
      return decodedResponse;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      if (e.toString().contains('TimeoutException')) {
        return {
          'status': false,
          'error': 'Connection timed out. Please try again.',
        };
      }

      return {
        'status': false,
        'error': 'Failed to connect to server',
      };
    }
  }

  // Add method to get stored UUID
  static Future<String?> getStoredUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uuid');
  }

  // Add method to get registration status
  static Future<String?> getRegProcess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reg_process');
  }

  // Add method to clear stored data (for logout)
  static Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uuid');
    await prefs.remove('reg_process');
  }
}
