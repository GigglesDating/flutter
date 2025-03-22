import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'config.dart';

class AuthProvider extends ChangeNotifier {
  String? _requestId;
  String? _uuid;
  String? _phoneNumber;
  String? _regProcess;
  bool _isLoading = false;
  bool _isAuthenticated = false;

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
    _uuid = prefs.getString('user_uuid');
    _phoneNumber = prefs.getString('phone_number');
    _regProcess = prefs.getString('reg_process');
    _isAuthenticated = _uuid != null;
    notifyListeners();
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOtp({
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http
          .post(
            Uri.parse(ApiConfig.functions),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'function': 'request_otp',
              'phoneNumber': '+91$phoneNumber',
            }),
          )
          .timeout(
            ApiConfig.connectionTimeout,
          );

      if (response.statusCode >= 500) {
        return {
          'status': false,
          'error': 'Server error occurred. Please try again later.',
        };
      }

      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse['requestId'] != null) {
        _requestId = decodedResponse['requestId'];
        _phoneNumber = phoneNumber;
        decodedResponse['status'] = true;
      }

      _isLoading = false;
      notifyListeners();
      return decodedResponse;
    } on TimeoutException {
      _isLoading = false;
      notifyListeners();
      return {
        'status': false,
        'error': 'Connection timed out. Please check your internet connection.',
      };
    } on http.ClientException {
      _isLoading = false;
      notifyListeners();
      return {
        'status': false,
        'error': 'Network error. Please check your internet connection.',
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'status': false,
        'error': 'An unexpected error occurred. Please try again.',
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
            Uri.parse(ApiConfig.functions),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'function': 'verify_otp',
              'phoneNumber': phoneNumber,
              'otp': otp,
              'requestId': requestId,
            }),
          )
          .timeout(
            ApiConfig.connectionTimeout,
          );

      if (response.statusCode >= 500) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodedResponse['uuid'] != null) {
          await _saveAuthData(
            uuid: decodedResponse['uuid'],
            phoneNumber: phoneNumber,
            regProcess: decodedResponse['reg_process'],
          );
        }
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

  // Save authentication data
  Future<void> _saveAuthData({
    required String uuid,
    required String phoneNumber,
    String? regProcess,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_uuid', uuid);
    await prefs.setString('phone_number', phoneNumber);
    if (regProcess != null) {
      await prefs.setString('reg_process', regProcess);
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
    await prefs.remove('user_uuid');
    await prefs.remove('phone_number');
    await prefs.remove('reg_process');

    _uuid = null;
    _phoneNumber = null;
    _regProcess = null;
    _isAuthenticated = false;
    _requestId = null;

    notifyListeners();
  }

  // Add this method after _saveAuthData
  Future<void> updateRegProcess(String regProcess) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reg_process', regProcess);
    _regProcess = regProcess;
    notifyListeners();
  }
}
