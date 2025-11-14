import 'package:flutter/material.dart';
import 'package:keep_it_grow/screens/auth/forgot_password_screen.dart';
import 'package:keep_it_grow/services/auth_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/role_based_navigator.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Fungsi untuk menampilkan error popup
  void _showErrorDialog(String message) {
    String cleanMessage = message
        .replaceAll('Exception: ', '')
        .replaceAll('http.', '')
        .trim();

    // Jika message kosong, beri default message
    if (cleanMessage.isEmpty) {
      cleanMessage = 'Terjadi kesalahan saat login';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 24),
              SizedBox(width: 8),
              Text(
                'Login Gagal',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            cleanMessage,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Color(0xFF3B82F6)),
              child: Text(
                'TUTUP',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk extract message dengan null safety yang lebih ketat
  String _extractErrorMessage(dynamic error) {
    try {
      if (error == null) {
        return 'Terjadi kesalahan yang tidak diketahui';
      }

      if (error is String) {
        return error.isNotEmpty ? error : 'Terjadi kesalahan';
      }

      if (error is Map<String, dynamic>) {
        // Cek berbagai kemungkinan key dengan null safety
        final message = error['message'] ?? error['error'];
        if (message != null && message is String && message.isNotEmpty) {
          return message;
        }

        final errors = error['errors'];
        if (errors != null) {
          if (errors is String) return errors;
          if (errors is Map) return errors.toString();
        }

        return 'Terjadi kesalahan';
      }

      if (error is http.Response) {
        // Handle HTTP response errors
        if (error.statusCode >= 400 && error.statusCode < 500) {
          return 'Email atau password salah';
        } else if (error.statusCode >= 500) {
          return 'Server sedang mengalami masalah';
        } else {
          return 'Koneksi gagal (Error ${error.statusCode})';
        }
      }

      return error.toString();
    } catch (e) {
      return 'Terjadi kesalahan saat memproses error';
    }
  }

  // Fungsi login yang diperbaiki
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Attempting login...');

      final response = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('Login successful, navigating...');

      // Navigasi ke role-based screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleBasedNavigator(user: response.user),
        ),
      );
    } on http.Response catch (response) {
      print('HTTP Error: ${response.statusCode}');
      print('Response body: ${response.body}');

      String errorMessage;

      try {
        // Coba parse JSON response
        final dynamic responseData = json.decode(response.body);
        errorMessage = _extractErrorMessage(responseData);
      } catch (e) {
        // Jika parsing gagal, gunakan status code
        errorMessage = _extractErrorMessage(response);
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      print('General error: $e');

      // Handle other errors
      final errorMessage = _extractErrorMessage(e);
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth * 0.85;

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: contentWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60), // Kurangi height agar ada ruang
                  // Header dengan Logo Custom
                  _buildHeader(),
                  SizedBox(height: 60), // Kurangi spacing
                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        _buildEmailField(),
                        SizedBox(height: 20),

                        // Password Field
                        _buildPasswordField(),
                        SizedBox(height: 16),

                        // Forgot Password Link - POSISINYA DI SINI
                        Container(
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFF3B82F6),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Login Button
                        _buildLoginButton(contentWidth),
                      ],
                    ),
                  ),

                  SizedBox(height: 40), // Tambah spacing di bawah
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo Custom
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Color(0xFF3B82F6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.psychology_rounded,
                  size: 50,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),
        SizedBox(height: 24),

        // Judul Aplikasi
        Text(
          'KeepItGrow',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),

        Text(
          'Selamat datang kembali',
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          hintText: 'masukkan email anda',
          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: 12, left: 16),
            child: Icon(Icons.email_outlined, color: Color(0xFF6B7280)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: Color(0xFF111827), fontSize: 16),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email harus diisi';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Format email tidak valid';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
          hintText: 'masukkan password anda',
          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: 12, left: 16),
            child: Icon(Icons.lock_outline_rounded, color: Color(0xFF6B7280)),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF6B7280),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFEF4444), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
        obscureText: _obscurePassword,
        style: TextStyle(color: Color(0xFF111827), fontSize: 16),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password harus diisi';
          }
          if (value.length < 6) {
            return 'Password minimal 6 karakter';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton(double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MASUK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
