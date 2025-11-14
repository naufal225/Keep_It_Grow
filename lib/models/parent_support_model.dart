class ParentSupport {
  final int id;
  final int studentId;
  final String studentName;
  final String? studentAvatar;
  final String message;
  final String sentAt;
  final String? readAt;
  final bool isRead;

  ParentSupport({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentAvatar,
    required this.message,
    required this.sentAt,
    this.readAt,
    required this.isRead,
  });

  factory ParentSupport.fromJson(Map<String, dynamic> json) {
    return ParentSupport(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? '',
      studentAvatar: json['student_avatar'],
      message: json['message'] ?? '',
      sentAt: json['sent_at'] ?? '',
      readAt: json['read_at'],
      isRead: json['is_read'] ?? false,
    );
  }
}

class SupportHistory {
  final List<ParentSupport> supports;
  final int totalSent;
  final int totalUnreadByStudents;

  SupportHistory({
    required this.supports,
    required this.totalSent,
    required this.totalUnreadByStudents,
  });

  factory SupportHistory.fromJson(Map<String, dynamic> json) {
    return SupportHistory(
      supports: (json['supports'] as List? ?? [])
          .map((support) => ParentSupport.fromJson(support))
          .toList(),
      totalSent: json['total_sent'] ?? 0,
      totalUnreadByStudents: json['total_unread_by_students'] ?? 0,
    );
  }
}