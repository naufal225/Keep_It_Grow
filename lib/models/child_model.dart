class Child {
  final int id;
  final String name;
  final String email;
  final int level;
  final int xp;
  final String? avatarUrl;
  final String className;
  final int weeklyActivity;
  final String lastActivity;

  Child({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.xp,
    this.avatarUrl,
    required this.className,
    required this.weeklyActivity,
    required this.lastActivity,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      avatarUrl: json['avatar_url'],
      className: json['class'] ?? 'Belum ada kelas',
      weeklyActivity: json['weekly_activity'] ?? 0,
      lastActivity: json['last_activity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level,
      'xp': xp,
      'avatar_url': avatarUrl,
      'class': className,
      'weekly_activity': weeklyActivity,
      'last_activity': lastActivity,
    };
  }
}