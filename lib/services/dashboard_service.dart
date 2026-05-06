// services/dashboard_service.dart
import 'dart:convert';
import 'package:keep_it_grow/services/auth_http.dart' as http;
import 'auth_service.dart';
import 'constants.dart';

class DashboardService {
  static const String baseUrl = ServiceConstants.apiBase;

  static Future<Map<String, dynamic>> getStudentDashboard() async {
    final token = await AuthService.requireToken();

    final response = await http.get(
      Uri.parse('$baseUrl/siswa/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Gagal memuat dashboard: ${response.statusCode}');
    }
  }
}
