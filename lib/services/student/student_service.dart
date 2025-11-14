import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../auth_service.dart';

class StudentService {
  StudentService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Token tidak tersedia. Silakan login kembali.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get full leaderboard
  Future<Map<String, dynamic>> getLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/siswa/leaderboard'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memuat leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat leaderboard: $e');
    }
  }

  // Get top 5 students
  Future<Map<String, dynamic>> getTopFive() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/siswa/leaderboard/top-five'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memuat top five: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat top five: $e');
    }
  }

  // Get student detail
  Future<Map<String, dynamic>> getStudentDetail(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/siswa/leaderboard/$studentId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Data siswa tidak ditemukan');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memuat detail siswa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat detail siswa: $e');
    }
  }

  // Get my own progress
  Future<Map<String, dynamic>> getMyProgress() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/siswa/leaderboard/my-progress'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memuat progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat progress: $e');
    }
  }
}