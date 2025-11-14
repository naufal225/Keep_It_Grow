// services/categories_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'constants.dart';

class CategoriesService {
  static const String baseUrl = ServiceConstants.apiBase;

  static Future<Map<String, dynamic>> getCategories() async {
    final token = await AuthService.getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/categories'), // Sesuaikan dengan endpoint categories Anda
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }
}