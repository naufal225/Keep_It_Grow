// models/user_model.dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? parentId;
  final String? avatarUrl;
  final int xp;
  final int level;
  final String? rememberToken;
  final String createdAt;
  final String updatedAt;
  final String username;
  final String? nis; // Tambahkan field NIS

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.parentId,
    this.avatarUrl,
    required this.xp,
    required this.level,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    this.nis, // Tambahkan di constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      parentId: json['parent_id'],
      avatarUrl: json['avatar_url'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      rememberToken: json['remember_token'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      username: json['username'] ?? '',
      nis: json['nis'], // Tambahkan parsing NIS
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'parent_id': parentId,
      'avatar_url': avatarUrl,
      'xp': xp,
      'level': level,
      'remember_token': rememberToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'username': username,
      'nis': nis, // Tambahkan NIS di toJson
    };
  }
}

class LoginResponse {
  final String message;
  final UserModel user;
  final String token;

  LoginResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'user': user.toJson(), 'token': token};
  }
}
