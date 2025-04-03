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
    debugPrint('Initializing auth from SharedPreferences...');

    _uuid = prefs.getString('user_uuid');
    _phoneNumber = prefs.getString('phone_number');
    _regProcess = prefs.getString('reg_process');
    _isAuthenticated = _uuid != null;

    debugPrint('Auth initialization complete:');
    debugPrint('UUID: $_uuid');
    debugPrint('Phone: $_phoneNumber');
    debugPrint('Reg Process: $_regProcess');
    debugPrint('Is Authenticated: $_isAuthenticated');

    notifyListeners();
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOtp({
    required String phoneNumber,
  }) async {
    try {
      // Input validation
      if (phoneNumber.isEmpty) {
        return {
          'status': false,
          'error': 'Phone number cannot be empty',
        };
      }

      // Basic phone number format validation (10 digits)
      if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
        return {
          'status': false,
          'error': 'Please enter a valid 10-digit phone number',
        };
      }

      _isLoading = true;
      notifyListeners();

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/request-otp/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'phoneNumber': '+91$phoneNumber',
            }),
          )
          .timeout(
            Duration(milliseconds: ApiConfig.connectionTimeout),
          );

      // Handle different status codes
      switch (response.statusCode) {
        case 200:
        case 201:
          try {
            final decodedResponse = jsonDecode(response.body);
            debugPrint('OTP Response: $decodedResponse');

            // Validate response structure
            if (decodedResponse['requestId'] == null) {
              return {
                'status': false,
                'error': 'Invalid response format: missing requestId',
              };
            }

            _requestId = decodedResponse['requestId'];
            _phoneNumber = phoneNumber;
            return {
              'status': true,
              'success': true,
              'requestId': decodedResponse['requestId'],
              'message': decodedResponse['message'] ?? 'OTP sent successfully',
            };
          } catch (e) {
            debugPrint('Error decoding response: $e');
            return {
              'status': false,
              'error': 'Invalid response format from server',
            };
          }

        case 400:
          return {
            'status': false,
            'error': 'Invalid request. Please check your phone number.',
          };

        case 401:
          return {
            'status': false,
            'error': 'Authentication failed. Please try again.',
          };

        case 403:
          return {
            'status': false,
            'error': 'Access denied. Please try again later.',
          };

        case 404:
          return {
            'status': false,
            'error': 'Service not found. Please try again later.',
          };

        case 429:
          return {
            'status': false,
            'error': 'Too many attempts. Please try again later.',
          };

        case 500:
          return {
            'status': false,
            'error': 'Server error occurred. Please try again later.',
          };

        default:
          debugPrint('Unexpected status code: ${response.statusCode}');
          return {
            'status': false,
            'error':
                'An unexpected error occurred (${response.statusCode}). Please try again.',
          };
      }
    } on TimeoutException {
      return {
        'status': false,
        'error': 'Connection timed out. Please check your internet connection.',
      };
    } on http.ClientException {
      return {
        'status': false,
        'error': 'Network error. Please check your internet connection.',
      };
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return {
        'status': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
    required String requestId,
  }) async {
    try {
      // Input validation
      if (phoneNumber.isEmpty || otp.isEmpty || requestId.isEmpty) {
        return {
          'status': false,
          'error': 'Phone number, OTP, and request ID are required',
        };
      }

      // Validate phone number format (10 digits)
      if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
        return {
          'status': false,
          'error': 'Please enter a valid 10-digit phone number',
        };
      }

      // Validate OTP format (4 digits as per login screen)
      if (!RegExp(r'^[0-9]{4}$').hasMatch(otp)) {
        return {
          'status': false,
          'error': 'Please enter a valid 4-digit OTP',
        };
      }

      // Validate requestId format
      if (_requestId == null || _requestId != requestId) {
        return {
          'status': false,
          'error': 'Invalid or expired request ID. Please request a new OTP.',
        };
      }

      _isLoading = true;
      notifyListeners();

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/verify-otp/'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'phoneNumber': '+91$phoneNumber',
              'requestId': requestId,
              'otp': otp,
            }),
          )
          .timeout(
            Duration(milliseconds: ApiConfig.connectionTimeout),
          );

      debugPrint('Verify OTP Response: ${response.body}');

      // Handle different status codes
      switch (response.statusCode) {
        case 200:
        case 201:
          try {
            final decodedResponse = jsonDecode(response.body);

            // Validate response structure
            if (decodedResponse['uuid'] == null) {
              return {
                'status': false,
                'error': 'Invalid response format: missing UUID',
              };
            }

            // Save authentication data
            await _saveAuthData(
              uuid: decodedResponse['uuid'],
              phoneNumber: phoneNumber,
              regProcess: decodedResponse['reg_process'],
            );

            return {
              'status': true,
              'success': true,
              'uuid': decodedResponse['uuid'],
              'message':
                  decodedResponse['message'] ?? 'OTP verified successfully',
              'reg_process': decodedResponse['reg_process'],
            };
          } catch (e) {
            debugPrint('Error decoding verify OTP response: $e');
            return {
              'status': false,
              'error': 'Invalid response format from server',
            };
          }

        case 400:
          return {
            'status': false,
            'error': 'Invalid OTP. Please check and try again.',
          };

        case 401:
          return {
            'status': false,
            'error': 'Authentication failed. Please try again.',
          };

        case 403:
          return {
            'status': false,
            'error': 'Access denied. Please try again later.',
          };

        case 404:
          return {
            'status': false,
            'error': 'Service not found. Please try again later.',
          };

        case 429:
          return {
            'status': false,
            'error': 'Too many attempts. Please try again later.',
          };

        case 500:
          return {
            'status': false,
            'error': 'Server error occurred. Please try again later.',
          };

        default:
          debugPrint(
              'Unexpected status code in verify OTP: ${response.statusCode}');
          return {
            'status': false,
            'error':
                'An unexpected error occurred (${response.statusCode}). Please try again.',
          };
      }
    } on TimeoutException {
      return {
        'status': false,
        'error': 'Connection timed out. Please check your internet connection.',
      };
    } on http.ClientException {
      return {
        'status': false,
        'error': 'Network error. Please check your internet connection.',
      };
    } catch (e) {
      debugPrint('Unexpected error in verify OTP: $e');
      return {
        'status': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save authentication data
  Future<void> _saveAuthData({
    required String uuid,
    required String phoneNumber,
    String? regProcess,
  }) async {
    debugPrint('Saving auth data...');
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

    debugPrint('Auth data saved:');
    debugPrint('UUID: $_uuid');
    debugPrint('Phone: $_phoneNumber');
    debugPrint('Reg Process: $_regProcess');
    debugPrint('Is Authenticated: $_isAuthenticated');

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
