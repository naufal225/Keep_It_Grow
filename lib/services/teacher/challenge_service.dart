import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../auth_service.dart';

class TeacherChallengeService {
  static Future<Map<String, dynamic>> getChallenges() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/challenges'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load challenges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load challenges: $e');
    }
  }

  static Future<Map<String, dynamic>> getChallengeDetail(int challengeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/challenges/$challengeId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load challenge detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load challenge detail: $e');
    }
  }

  static Future<Map<String, dynamic>> getWaitingValidation() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/guru/challenges/waiting-validation'),
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

  static Future<Map<String, dynamic>> approveSubmission(int participantId) async {
    try {
      final response = await http.post(
        Uri.parse('${ServiceConstants.apiBase}/guru/challenges/$participantId/approve'),
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

  static Future<Map<String, dynamic>> rejectSubmission(int participantId) async {
    try {
      final response = await http.post(
        Uri.parse('${ServiceConstants.apiBase}/guru/challenges/$participantId/reject'),
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