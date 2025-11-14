import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:keep_it_grow/services/auth_service.dart';
import 'package:keep_it_grow/services/constants.dart';

class GuruDashboardService {
  static const String baseUrl = ServiceConstants.apiBase;
  static Future<Map<String, dynamic>> getGuruDashboard() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guru/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }
}