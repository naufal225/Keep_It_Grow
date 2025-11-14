// services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_service.dart';
import 'constants.dart';

class ProfileService {
  static const String baseUrl = ServiceConstants.apiBase;

  static Future<UserModel> getUserProfile() async {
    final token = await AuthService.getToken();
    
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final user = UserModel.fromJson(responseData);
      
      // Update user data di local storage
      await AuthService.saveUser(user);
      
      return user;
    } else if (response.statusCode == 401) {
      // Token expired atau invalid
      await AuthService.clearAuthData();
      throw Exception('Sesi telah berakhir. Silakan login kembali.');
    } else {
      throw Exception('Gagal memuat profil: ${response.statusCode}');
    }
  }

  static Future<UserModel> updateUserProfile(Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final user = UserModel.fromJson(responseData['user'] ?? responseData);
      
      // Update user data di local storage
      await AuthService.saveUser(user);
      
      return user;
    } else if (response.statusCode == 401) {
      await AuthService.clearAuthData();
      throw Exception('Sesi telah berakhir. Silakan login kembali.');
    } else {
      throw Exception('Gagal memperbarui profil: ${response.statusCode}');
    }
  }
}