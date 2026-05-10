import 'dart:convert';

import 'package:keep_it_grow/services/auth_http.dart' as http;

import 'auth_service.dart';
import 'constants.dart';

class ReflectionService {
  static const String baseUrl = '${ServiceConstants.apiBase}/siswa';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.requireToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 15));

    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(body);
    }

    throw Exception(body['message'] ?? 'Request gagal: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _getHeaders(),
      body: json.encode(payload),
    ).timeout(const Duration(seconds: 15));

    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(body);
    }

    throw Exception(body['message'] ?? 'Request gagal: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getActiveReflectionTemplate() async {
    return _get('/reflection-template/active');
  }

  static Future<Map<String, dynamic>> getActiveReflectionSubmission() async {
    return _get('/reflection-template/active/submission');
  }

  static Future<Map<String, dynamic>> saveReflectionDraft(
    Map<String, dynamic> payload,
  ) async {
    return _post('/reflection-template/active/draft', payload);
  }

  static Future<Map<String, dynamic>> submitReflectionTemplate(
    Map<String, dynamic> payload,
  ) async {
    return _post('/reflection-template/active/submit', payload);
  }

  static Future<Map<String, dynamic>> getReflectionTemplateHistory() async {
    return _get('/reflection-template/history');
  }

  static Future<Map<String, dynamic>> getReflectionTemplateHistoryDetail(
    int id,
  ) async {
    return _get('/reflection-template/history/$id');
  }

  // Legacy methods are kept during rollout to avoid breaking older screens.
  static Future<Map<String, dynamic>> getReflections({
    String? date,
    String? month,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/reflections');

      final params = <String, String>{};
      if (date != null) params['date'] = date;
      if (month != null) params['month'] = month;

      final response = await http.get(
        url.replace(queryParameters: params),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      }
    } catch (_) {}

    return {'data': []};
  }

  static Future<Map<String, dynamic>> getTodayReflection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reflections/today'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      }
    } catch (_) {}

    return {'status': 'success', 'data': null};
  }

  static Future<Map<String, dynamic>> getReflectionStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reflections/stats'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      }
    } catch (_) {}

    return {
      'data': {
        'total_reflections': 0,
        'reflections_with_body': 0,
        'current_streak': 0,
        'mood_distribution': {}
      }
    };
  }

  static Future<Map<String, dynamic>> createReflection(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reflections'),
      headers: await _getHeaders(),
      body: json.encode({
        'mood': data['mood'],
        'body': data['body'],
        'date': data['date'],
      }),
    ).timeout(const Duration(seconds: 15));

    final body = json.decode(response.body);
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(body);
    }

    throw Exception(body['message'] ?? 'Failed to create reflection');
  }

  static Future<Map<String, dynamic>> updateReflection(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reflections/$id'),
      headers: await _getHeaders(),
      body: json.encode({
        if (data.containsKey('mood')) 'mood': data['mood'],
        if (data.containsKey('body')) 'body': data['body'],
        if (data.containsKey('date')) 'date': data['date'],
      }),
    ).timeout(const Duration(seconds: 15));

    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(body);
    }

    throw Exception(body['message'] ?? 'Failed to update reflection');
  }

  static Future<void> deleteReflection(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reflections/$id'),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to delete reflection');
    }
  }
}
