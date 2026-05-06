// services/profile_service.dart
import 'dart:convert';
import 'package:keep_it_grow/services/auth_http.dart' as http;
import '../models/user_model.dart';
import 'auth_service.dart';
import 'constants.dart';

class ProfileService {
  static const String baseUrl = ServiceConstants.apiBase;

  static Future<UserModel> getUserProfile() async {
    final token = await AuthService.requireToken();

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
    } else {
      throw Exception('Gagal memuat profil: ${response.statusCode}');
    }
  }

  static Future<UserModel> updateUserProfile(Map<String, dynamic> data) async {
    final token = await AuthService.requireToken();

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
    } else {
      throw Exception('Gagal memperbarui profil: ${response.statusCode}');
    }
  }
}
