import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
        // If we got a requestId, the OTP was sent successfully
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

      final decodedResponse = jsonDecode(response.body);

      // Set status to true if verification is successful
      if (response.statusCode == 200 || decodedResponse['success'] == true) {
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
}
