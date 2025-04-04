import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class DatabaseProvider {
  DatabaseProvider() {
    try {
      // Ensure background isolate messenger is initialized
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken != null) {
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        debugPrint(
            'BackgroundIsolateBinaryMessenger initialized in DatabaseProvider');
      }
      debugPrint('DatabaseProvider initialized successfully');
    } catch (e) {
      debugPrint('Error initializing DatabaseProvider: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getData({
    required String uuid,
    required String bucket,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.database}$uuid/$bucket/'),
        headers: ApiConfig.headers,
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
        Uri.parse('${ApiConfig.database}$uuid/$bucket/'),
        headers: ApiConfig.headers,
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }
}
