import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ReflectionService {
  static const String baseUrl = '${ServiceConstants.apiBase}/siswa';

  static Future<Map<String, String>> _getHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      print('🔑 Token from storage: ${token != null ? "Available" : "NULL"}');
      
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('❌ Error getting headers: $e');
      rethrow;
    }
  }

  // Get all reflections with optional filtering
  static Future<Map<String, dynamic>> getReflections({
    String? date,
    String? month,
  }) async {
    try {
      print('🚀 Starting getReflections API call...');
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/reflections');
      
      final params = <String, String>{};
      if (date != null) params['date'] = date;
      if (month != null) params['month'] = month;

      print('📡 URL: $url');
      print('🔧 Params: $params');

      final response = await http.get(
        url.replace(queryParameters: params),
        headers: headers,
      ).timeout(Duration(seconds: 15));

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Successfully loaded ${data['data']?.length ?? 0} reflections');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint tidak ditemukan.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load reflections: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getReflections: $e');
      // Return empty array instead of throwing error
      return {'data': []};
    }
  }

  // Get today's reflection - Improved null handling
  static Future<Map<String, dynamic>> getTodayReflection() async {
    try {
      print('🚀 Starting getTodayReflection API call...');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reflections/today'),
        headers: headers,
      ).timeout(Duration(seconds: 15));

      print('📥 Today Reflection Response Status: ${response.statusCode}');
      print('📥 Today Reflection Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Today reflection loaded: ${data['data'] != null ? "Available" : "Null"}');
        return data;
      } else if (response.statusCode == 404) {
        // Return data dengan null value
        return {'status': 'success', 'data': null};
      } else {
        final errorData = json.decode(response.body);
        print('⚠️ API Error: ${errorData['message']}');
        // Return data dengan null value instead of throwing error
        return {'status': 'success', 'data': null};
      }
    } catch (e) {
      print('❌ Error in getTodayReflection: $e');
      // Return data dengan null value instead of throwing error
      return {'status': 'success', 'data': null};
    }
  }

  // Get reflection statistics
  static Future<Map<String, dynamic>> getReflectionStats() async {
    try {
      print('🚀 Starting getReflectionStats API call...');
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/reflections/stats'),
        headers: headers,
      ).timeout(Duration(seconds: 15));

      print('📥 Stats Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Stats loaded successfully');
        return data;
      } else {
        // Return default stats instead of throwing error
        return {
          'data': {
            'total_reflections': 0,
            'reflections_with_body': 0,
            'current_streak': 0,
            'mood_distribution': {}
          }
        };
      }
    } catch (e) {
      print('❌ Error in getReflectionStats: $e');
      // Return default stats instead of throwing error
      return {
        'data': {
          'total_reflections': 0,
          'reflections_with_body': 0,
          'current_streak': 0,
          'mood_distribution': {}
        }
      };
    }
  }

  // Create new reflection
  static Future<Map<String, dynamic>> createReflection(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      
      // Pastikan menggunakan field 'body'
      final reflectionData = {
        'mood': data['mood'],
        'body': data['body'], // Gunakan body
        'date': data['date'],
      };

      final response = await http.post(
        Uri.parse('$baseUrl/reflections'),
        headers: headers,
        body: json.encode(reflectionData),
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create reflection');
      }
    } catch (e) {
      throw Exception('Failed to create reflection: $e');
    }
  }

  // Update reflection
  static Future<Map<String, dynamic>> updateReflection(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      
      // Pastikan menggunakan field 'body'
      final updateData = {
        if (data.containsKey('mood')) 'mood': data['mood'],
        if (data.containsKey('body')) 'body': data['body'], // Gunakan body
        if (data.containsKey('date')) 'date': data['date'],
      };

      final response = await http.put(
        Uri.parse('$baseUrl/reflections/$id'),
        headers: headers,
        body: json.encode(updateData),
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update reflection');
      }
    } catch (e) {
      throw Exception('Failed to update reflection: $e');
    }
  }

  // Delete reflection
  static Future<void> deleteReflection(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/reflections/$id'),
        headers: headers,
      ).timeout(Duration(seconds: 15));

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete reflection');
      }
    } catch (e) {
      throw Exception('Failed to delete reflection: $e');
    }
  }
}