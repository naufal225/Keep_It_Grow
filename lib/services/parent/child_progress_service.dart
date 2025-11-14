import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:keep_it_grow/services/auth_service.dart';
import 'package:keep_it_grow/services/constants.dart';

class ChildProgressService {
  static const String baseUrl = ServiceConstants.apiBase;
  
  /// Mendapatkan progress detail untuk satu anak
  static Future<Map<String, dynamic>> getChildProgress(int childId) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ortu/child-progress/$childId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load child progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load child progress: $e');
    }
  }

  /// Mendapatkan data semua anak (untuk segmented control)
  static Future<Map<String, dynamic>> getAllChildrenProgress() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ortu/child-progress'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load children data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load children data: $e');
    }
  }
}