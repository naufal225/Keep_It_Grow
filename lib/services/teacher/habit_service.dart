import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../auth_service.dart';

class TeacherHabitService {
  static Future<Map<String, dynamic>> getHabits() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/habits'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load habits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load habits: $e');
    }
  }

  static Future<Map<String, dynamic>> getHabitDetail(int habitId) async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/habits/$habitId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load habit detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load habit detail: $e');
    }
  }

  static Future<Map<String, dynamic>> getWaitingValidation() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/habits/waiting-validation'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load waiting validation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load waiting validation: $e');
    }
  }

  static Future<Map<String, dynamic>> getTodaySubmissions() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/habits/today-submissions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load today submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load today submissions: $e');
    }
  }

  static Future<Map<String, dynamic>> approveSubmission(int logId) async {
    try {
      final response = await http.post(
        Uri.parse('${ServiceConstants.apiBase}/guru/habits/$logId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to approve submission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to approve submission: $e');
    }
  }

  static Future<Map<String, dynamic>> rejectSubmission(int logId) async {
    try {
      final response = await http.post(
        Uri.parse('${ServiceConstants.apiBase}/guru/habits/$logId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to reject submission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to reject submission: $e');
    }
  }
}