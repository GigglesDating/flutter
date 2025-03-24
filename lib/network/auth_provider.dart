import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'config.dart';

class AuthProvider extends ChangeNotifier {
  // Private fields
  String? _requestId;
  String? _uuid;
  String? _phoneNumber;
  String? _regProcess;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  // SharedPreferences keys
  static const String _keyUuid = 'user_uuid';
  static const String _keyPhone = 'phone_number';
  static const String _keyRegProcess = 'reg_process';

  // Function names
  static const String _functionRequestOtp = 'request_otp';
  static const String _functionVerifyOtp = 'verify_otp';

  // Getters
  bool get isLoading => _isLoading;
  String? get requestId => _requestId;
  String? get uuid => _uuid;
  String? get phoneNumber => _phoneNumber;
  String? get regProcess => _regProcess;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize from SharedPreferences
  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _uuid = prefs.getString(_keyUuid);
    _phoneNumber = prefs.getString(_keyPhone);
    _regProcess = prefs.getString(_keyRegProcess);
    _isAuthenticated = _uuid != null;
    notifyListeners();
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOtp({
    required String phoneNumber,
  }) async {
    try {
      _setLoading(true);

      final response = await http
          .post(
            Uri.parse(ApiConfig.functionsEndpoint),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'function': _functionRequestOtp,
              'phoneNumber': '+91$phoneNumber',
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode >= ApiConfig.statusServerError) {
        return _createErrorResponse(
            'Server error occurred. Please try again later.');
      }

      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse['requestId'] != null) {
        _requestId = decodedResponse['requestId'];
        _phoneNumber = phoneNumber;
        decodedResponse['status'] = true;
      }

      return decodedResponse;
    } on TimeoutException {
      return _createErrorResponse(
          'Connection timed out. Please check your internet connection.');
    } on http.ClientException {
      return _createErrorResponse(
          'Network error. Please check your internet connection.');
    } catch (e) {
      return _createErrorResponse(
          'An unexpected error occurred. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
    required String requestId,
  }) async {
    try {
      _setLoading(true);

      final response = await http
          .post(
            Uri.parse(ApiConfig.functionsEndpoint),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'function': _functionVerifyOtp,
              'phoneNumber': phoneNumber,
              'otp': otp,
              'requestId': requestId,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode >= ApiConfig.statusServerError) {
        return _createErrorResponse(
            'Server error occurred. Please try again later.');
      }

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode == ApiConfig.statusOk ||
          response.statusCode == 201) {
        // Consider adding 201 to ApiConfig if needed
        if (decodedResponse['uuid'] != null) {
          await _saveAuthData(
            uuid: decodedResponse['uuid'],
            phoneNumber: phoneNumber,
            regProcess: decodedResponse['reg_process'],
          );
        }
        decodedResponse['status'] = true;
      }

      return decodedResponse;
    } catch (e) {
      return _createErrorResponse('Failed to connect to server');
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to create error response
  Map<String, dynamic> _createErrorResponse(String message) {
    return {
      'status': false,
      'error': message,
    };
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Save authentication data
  Future<void> _saveAuthData({
    required String uuid,
    required String phoneNumber,
    String? regProcess,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyUuid, uuid);
    await prefs.setString(_keyPhone, phoneNumber);
    if (regProcess != null) {
      await prefs.setString(_keyRegProcess, regProcess);
    }

    _uuid = uuid;
    _phoneNumber = phoneNumber;
    _regProcess = regProcess;
    _isAuthenticated = true;

    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUuid);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyRegProcess);

    _uuid = null;
    _phoneNumber = null;
    _regProcess = null;
    _isAuthenticated = false;
    _requestId = null;

    notifyListeners();
  }

  // Update registration process
  Future<void> updateRegProcess(String regProcess) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegProcess, regProcess);
    _regProcess = regProcess;
    notifyListeners();
  }
}
