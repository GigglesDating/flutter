import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class DatabaseProvider {
  Future<Map<String, dynamic>> getData({
    required String uuid,
    required String bucket,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.database),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'function': 'get_data',
          'uuid': uuid,
          'bucket': bucket,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  Future<Map<String, dynamic>> updateData({
    required String uuid,
    required String bucket,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.database),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'function': 'update_data',
          'uuid': uuid,
          'bucket': bucket,
          'data': data,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }
}
