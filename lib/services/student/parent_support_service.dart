import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../auth_service.dart';
import 'package:keep_it_grow/models/student_parent_support_models.dart';

class ParentSupportService {
  ParentSupportService();

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

  // Get all parent supports - RETURN MODEL LANGSUNG
  Future<StudentParentSupportResponse> getParentSupports() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/siswa/parent-supports'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return StudentParentSupportResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memuat pesan dukungan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat pesan dukungan: $e');
    }
  }

  // Get unread count - RETURN INT LANGSUNG
  Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/siswa/parent-supports/unread-count'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']['unread_count'] ?? 0;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memuat jumlah pesan belum dibaca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat jumlah pesan belum dibaca: $e');
    }
  }

  // Get latest supports for dashboard - RETURN MODEL LANGSUNG
  Future<StudentLatestSupportsResponse> getLatestSupports() async {
    try {
      final response = await http.get(
        Uri.parse('${ServiceConstants.apiBase}/siswa/parent-supports/latest'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return StudentLatestSupportsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memuat pesan terbaru: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat pesan terbaru: $e');
    }
  }

  // Mark all as read - TIDAK PERLU RETURN
  Future<void> markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('${ServiceConstants.apiBase}/siswa/parent-supports/mark-all-read'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menandai pesan sebagai sudah dibaca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal menandai pesan sebagai sudah dibaca: $e');
    }
  }

  // Mark specific support as read - TIDAK PERLU RETURN
  Future<void> markAsRead(int supportId) async {
    try {
      final response = await http.post(
        Uri.parse('${ServiceConstants.apiBase}/siswa/parent-supports/$supportId/mark-read'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Pesan dukungan tidak ditemukan');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menandai pesan sebagai sudah dibaca: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal menandai pesan sebagai sudah dibaca: $e');
    }
  }
}