import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../auth_service.dart';

class TeacherStudentService {
  static Future<Map<String, dynamic>> getStudents() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/students'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  static Future<Map<String, dynamic>> getStudentDetail(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/students/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load student detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load student detail: $e');
    }
  }
}
