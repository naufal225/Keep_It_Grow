// services/challenges_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'constants.dart';

class ChallengesService {
  static const String baseUrl = ServiceConstants.apiBase;

  // Get all challenges for student
  static Future<Map<String, dynamic>> getStudentChallenges() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/siswa/challenges'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memuat challenges');
    }
  }

  // Get challenges by status
  static Future<Map<String, dynamic>> getStudentChallengesByStatus(
    String status,
  ) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/siswa/challenges?status=$status'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memuat challenges');
    }
  }

  // Create new challenge
  static Future<Map<String, dynamic>> createChallenge(
    Map<String, dynamic> data,
  ) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/siswa/challenges'),
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
      throw Exception(errorData['message'] ?? 'Gagal membuat challenge');
    }
  }

  // Update challenge
  static Future<Map<String, dynamic>> updateChallenge(
    int id,
    Map<String, dynamic> data,
  ) async {
    final token = await AuthService.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/siswa/challenges/$id'),
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
      throw Exception(errorData['message'] ?? 'Gagal mengupdate challenge');
    }
  }

  // Delete challenge
  static Future<void> deleteChallenge(int id) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/siswa/challenges/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal menghapus challenge');
    }
  }
 
  // Get challenge detail
  static Future<Map<String, dynamic>> getChallengeDetail(int id) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/siswa/challenges/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memuat detail challenge');
    }
  }

  // Join challenge
  static Future<Map<String, dynamic>> joinChallenge(int challengeId) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/siswa/challenges/$challengeId/join'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal join challenge');
    }
  }

  // Submit proof for challenge
  static Future<Map<String, dynamic>> submitProof(
    int challengeId,
    String proofImagePath,
  ) async {
    final token = await AuthService.getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/siswa/challenges/$challengeId/submit-proof'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.files.add(
      await http.MultipartFile.fromPath('proof_image', proofImagePath),
    );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      final errorData = json.decode(responseData);
      throw Exception(errorData['message'] ?? 'Gagal submit proof');
    }
  }
}
