import 'dart:convert';
import 'dart:async'; // Add this import for TimeoutException
import 'package:http/http.dart' as http;
import 'config.dart';

class DatabaseProvider {
  // Function names
  static const String _functionGetData = 'get_data';
  static const String _functionUpdateData = 'update_data';

  // Error messages
  static const String _errorGetData = 'Failed to get data';
  static const String _errorUpdateData = 'Failed to update data';

  /// Fetches data from specified bucket for a user
  ///
  /// Parameters:
  /// - [uuid]: User's unique identifier
  /// - [bucket]: Database bucket name
  ///
  /// Returns a Map containing the response data or error
  Future<Map<String, dynamic>> getData({
    required String uuid,
    required String bucket,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.databaseEndpoint),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'function': _functionGetData,
              'uuid': uuid,
              'bucket': bucket,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode >= ApiConfig.statusServerError) {
        return {'status': 'error', 'message': '$_errorGetData: Server error'};
      }

      final decodedResponse = jsonDecode(response.body);
      return decodedResponse;
    } catch (e) {
      // Single catch block with error type checking
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Connection timeout';
      } else if (e is http.ClientException) {
        errorMessage = 'Network error';
      } else {
        errorMessage = e.toString();
      }

      return {'status': 'error', 'message': '$_errorGetData: $errorMessage'};
    }
  }

  /// Updates data in specified bucket for a user
  ///
  /// Parameters:
  /// - [uuid]: User's unique identifier
  /// - [bucket]: Database bucket name
  /// - [data]: Map containing the data to update
  ///
  /// Returns a Map containing the response data or error
  Future<Map<String, dynamic>> updateData({
    required String uuid,
    required String bucket,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.databaseEndpoint),
            headers: ApiConfig.headers,
            body: jsonEncode({
              'function': _functionUpdateData,
              'uuid': uuid,
              'bucket': bucket,
              'data': data,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode >= ApiConfig.statusServerError) {
        return {
          'status': 'error',
          'message': '$_errorUpdateData: Server error'
        };
      }

      final decodedResponse = jsonDecode(response.body);
      return decodedResponse;
    } catch (e) {
      // Single catch block with error type checking
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Connection timeout';
      } else if (e is http.ClientException) {
        errorMessage = 'Network error';
      } else {
        errorMessage = e.toString();
      }

      return {'status': 'error', 'message': '$_errorUpdateData: $errorMessage'};
    }
  }
}
