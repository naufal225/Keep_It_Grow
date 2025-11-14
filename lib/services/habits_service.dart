import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'constants.dart';

class HabitsService {
  static const String baseUrl = ServiceConstants.apiBase;

  // Get all habits for student
  static Future<Map<String, dynamic>> getStudentHabits() async {
    final token = await AuthService.getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/siswa/habits'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memuat habits');
    }
  }

  // Get habits by status
  static Future<Map<String, dynamic>> getStudentHabitsByStatus(String status) async {
    final token = await AuthService.getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/siswa/habits?status=$status'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memuat habits');
    }
  }

  // Create new habit
  static Future<Map<String, dynamic>> createHabit(Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/siswa/habits'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal membuat habit');
    }
  }

  // Update habit
  static Future<Map<String, dynamic>> updateHabit(int id, Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    
    final response = await http.put(
      Uri.parse('$baseUrl/siswa/habits/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal mengupdate habit');
    }
  }

  // Delete habit
  static Future<void> deleteHabit(int id) async {
    final token = await AuthService.getToken();
    
    final response = await http.delete(
      Uri.parse('$baseUrl/siswa/habits/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal menghapus habit');
    }
  }

  // Get habit detail
  static Future<Map<String, dynamic>> getHabitDetail(int id) async {
    final token = await AuthService.getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/siswa/habits/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memuat detail habit');
    }
  }

  // Join habit
  static Future<Map<String, dynamic>> joinHabit(int habitId) async {
    final token = await AuthService.getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/siswa/habits/$habitId/join'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal join habit');
    }
  }

  // Submit proof for habit
  static Future<Map<String, dynamic>> submitProof(
    int habitId,
    String proofImagePath,
    String note,
  ) async {
    final token = await AuthService.getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/siswa/habits/$habitId/submit-proof'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.files.add(
      await http.MultipartFile.fromPath('proof_image', proofImagePath),
    );

    request.fields['note'] = note;

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      final errorData = json.decode(responseData);
      throw Exception(errorData['message'] ?? 'Gagal submit proof');
    }
  }

  // Get habit logs
  static Future<Map<String, dynamic>> getHabitLogs(int habitId) async {
    final token = await AuthService.getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/siswa/habits/$habitId/logs'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memuat logs habit');
    }
  }

  // Get today's habits
  static Future<Map<String, dynamic>> getTodayHabits() async {
    final token = await AuthService.getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/siswa/habits/today'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memuat habits hari ini');
    }
  }
}