class StudentParentSupport {
  final int id;
  final String parentName;
  final String parentUsername;
  final String? parentAvatarUrl;
  final String message;
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final String timeAgo;

  StudentParentSupport({
    required this.id,
    required this.parentName,
    required this.parentUsername,
    this.parentAvatarUrl,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.timeAgo,
  });

  factory StudentParentSupport.fromJson(Map<String, dynamic> json) {
    return StudentParentSupport(
      id: json['id'] ?? 0,
      parentName: json['parent_name'] ?? '',
      parentUsername: json['parent_username'] ?? '',
      parentAvatarUrl: json['parent_avatar_url'],
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      timeAgo: json['time_ago'] ?? '',
    );
  }
}

class StudentParentSupportResponse {
  final List<StudentParentSupport> parentSupports;
  final int unreadCount;
  final int totalCount;

  StudentParentSupportResponse({
    required this.parentSupports,
    required this.unreadCount,
    required this.totalCount,
  });

  factory StudentParentSupportResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return StudentParentSupportResponse(
      parentSupports: (data['parent_supports'] as List)
          .map((item) => StudentParentSupport.fromJson(item))
          .toList(),
      unreadCount: data['unread_count'] ?? 0,
      totalCount: data['total_count'] ?? 0,
    );
  }
}

class StudentLatestSupportsResponse {
  final List<StudentParentSupport> latestSupports;
  final int unreadCount;

  StudentLatestSupportsResponse({
    required this.latestSupports,
    required this.unreadCount,
  });

  factory StudentLatestSupportsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return StudentLatestSupportsResponse(
      latestSupports: (data['latest_supports'] as List)
          .map((item) => StudentParentSupport.fromJson(item))
          .toList(),
      unreadCount: data['unread_count'] ?? 0,
    );
  }
}