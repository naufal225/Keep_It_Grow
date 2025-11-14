import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/constants.dart';
import '../../services/auth_service.dart';

class ParentSupportService {
  static const String baseUrl = ServiceConstants.apiBase;

  /// Mengirim pesan dukungan ke anak
  static Future<Map<String, dynamic>> sendSupport({
    required int studentId,
    required String message,
  }) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ortu/supports'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'student_id': studentId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error saat mengirim support: ${response.body}, student id : ${studentId}}");
        throw Exception('Failed to send support: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send support: $e');
    }
  }

  /// Mendapatkan riwayat pesan dukungan
  static Future<Map<String, dynamic>> getSupportHistory() async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ortu/supports'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load support history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load support history: $e');
    }
  }

  /// Mendapatkan detail pesan dukungan
  static Future<Map<String, dynamic>> getSupportDetail(int supportId) async {
    final token = await AuthService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ortu/supports/$supportId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load support detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load support detail: $e');
    }
  }
}