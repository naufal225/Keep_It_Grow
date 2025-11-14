import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:keep_it_grow/services/auth_service.dart';
import 'package:keep_it_grow/services/constants.dart';

class ParentDashboardService {
  static const String baseUrl = ServiceConstants.apiBase;
  
  static Future<Map<String, dynamic>> getParentDashboard() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ortu/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load parent dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load parent dashboard: $e');
    }
  }

  static Future<Map<String, dynamic>> getChildDetail(int childId) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ortu/dashboard/child/$childId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load child detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load child detail: $e');
    }
  }
}