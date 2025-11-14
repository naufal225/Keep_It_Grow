// services/dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'constants.dart';

class DashboardService {
  static const String baseUrl = ServiceConstants.apiBase;

  static Future<Map<String, dynamic>> getStudentDashboard() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

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
    } else if (response.statusCode == 401) {
      await AuthService.clearAuthData();
      throw Exception('Sesi telah berakhir. Silakan login kembali.');
    } else {
      throw Exception('Gagal memuat dashboard: ${response.statusCode}');
    }
  }
}
