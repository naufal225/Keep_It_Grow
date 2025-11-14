// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = ServiceConstants.apiBase;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Helper method untuk handle shared preferences errors
  static Future<SharedPreferences> _getPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      throw Exception('Gagal mengakses storage: $e');
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Error saving token: $e');
      throw Exception('Gagal menyimpan token');
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await _getPreferences();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  static Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setString(_userKey, json.encode(user.toJson()));
    } catch (e) {
      print('Error saving user: $e');
      throw Exception('Gagal menyimpan data user');
    }
  }

  static Future<UserModel?> getUser() async {
    try {
      final prefs = await _getPreferences();
      final userString = prefs.getString(_userKey);
      if (userString != null) {
        final userMap = json.decode(userString);
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> clearAuthData() async {
    try {
      final prefs = await _getPreferences();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      print('Error clearing auth data: $e');
      throw Exception('Gagal menghapus data auth');
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  static Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);

        await saveToken(loginResponse.token);
        await saveUser(loginResponse.user);

        return loginResponse;
      } else {
        throw Exception('${json.decode(response.body)["message"]}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Function logout yang baru
  static Future<void> logout() async {
    try {
      final token = await getToken();
      
      if (token != null && token.isNotEmpty) {
        // Panggil API logout jika token tersedia
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: 10));

        // Handle response dari server
        if (response.statusCode == 200) {
          print('Logout berhasil dari server');
        } else {
          print('Logout API response: ${response.statusCode}');
          // Tetap lanjutkan clear data lokal meskipun API gagal
        }
      }

      // Selalu clear data lokal terlepas dari response API
      await clearAuthData();
      
    } catch (e) {
      print('Error during logout: $e');
      // Tetap clear data lokal meskipun ada error
      await clearAuthData();
      // Tidak perlu rethrow karena kita ingin logout tetap berhasil
      // meskipun koneksi bermasalah
    }
  }

  // FORGOT PASSWORD METHODS
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/check-email'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email}),
          )
          .timeout(Duration(seconds: 10));

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'exists': responseData['exists'],
          'message': responseData['message'],
          'data': responseData['data']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      print('Check email error: $e');
      return {
        'success': false,
        'message': 'Koneksi gagal. Periksa koneksi internet Anda.',
      };
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email}),
          )
          .timeout(Duration(seconds: 10));

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      print('Forgot password error: $e');
      return {
        'success': false,
        'message': 'Koneksi gagal. Periksa koneksi internet Anda.',
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'token': token,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(Duration(seconds: 10));

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      print('Reset password error: $e');
      return {
        'success': false,
        'message': 'Koneksi gagal. Periksa koneksi internet Anda.',
      };
    }
  }

  static Future<Map<String, dynamic>> validateResetToken({
    required String email,
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/validate-reset-token'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'token': token,
            }),
          )
          .timeout(Duration(seconds: 10));

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success']) {
        return {
          'success': true,
          'valid': responseData['valid'],
          'message': responseData['message'],
          'data': responseData['data']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Token tidak valid',
        };
      }
    } catch (e) {
      print('Validate token error: $e');
      return {
        'success': false,
        'message': 'Koneksi gagal. Periksa koneksi internet Anda.',
      };
    }
  }
}