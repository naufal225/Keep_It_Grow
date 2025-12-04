import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';
import '../constants.dart';
import 'package:keep_it_grow/models/student_reward_models.dart';

class RewardService {
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

  Future<List<StudentReward>> getRewards({
    String? search,
    String? type,
    bool? affordable,
  }) async {
    final query = <String, String>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (type != null && type.isNotEmpty && type != 'all') query['type'] = type;
    if (affordable == true) query['affordable'] = 'true';

    final uri = Uri.parse('${ServiceConstants.apiBase}/siswa/rewards')
        .replace(queryParameters: query.isEmpty ? null : query);

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List<dynamic>;
      return data.map((e) => StudentReward.fromJson(e)).toList();
    }

    final message =
        json.decode(response.body)['message'] ?? 'Gagal memuat reward';
    throw Exception(message);
  }

  Future<StudentReward> getRewardDetail(int id) async {
    final response = await http.get(
      Uri.parse('${ServiceConstants.apiBase}/siswa/rewards/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return StudentReward.fromJson(data);
    }

    final message =
        json.decode(response.body)['message'] ?? 'Reward tidak ditemukan';
    throw Exception(message);
  }

  Future<StudentRewardRequest> requestReward(int id, int quantity) async {
    final response = await http.post(
      Uri.parse('${ServiceConstants.apiBase}/siswa/rewards/$id/request'),
      headers: await _getHeaders(),
      body: json.encode({'quantity': quantity}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body)['data'];
      return StudentRewardRequest.fromJson(data);
    }

    final message = json.decode(response.body)['message'] ??
        'Gagal mengajukan request reward';
    throw Exception(message);
  }

  Future<List<StudentRewardRequest>> getRewardRequests({
    String? status,
    String? search,
  }) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      query['status'] = status;
    }
    if (search != null && search.isNotEmpty) query['search'] = search;

    final uri = Uri.parse('${ServiceConstants.apiBase}/siswa/reward-requests')
        .replace(queryParameters: query.isEmpty ? null : query);

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List<dynamic>;
      return data.map((e) => StudentRewardRequest.fromJson(e)).toList();
    }

    final message = json.decode(response.body)['message'] ??
        'Gagal memuat request reward';
    throw Exception(message);
  }

  Future<StudentRewardRequest> getRewardRequestDetail(int id) async {
    final response = await http.get(
      Uri.parse('${ServiceConstants.apiBase}/siswa/reward-requests/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return StudentRewardRequest.fromJson(data);
    }

    final message = json.decode(response.body)['message'] ??
        'Request reward tidak ditemukan';
    throw Exception(message);
  }
}
