class Student {
  final int id;
  final String name;
  final String username;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int rank;
  final int habitsCompletedCount;
  final int challengesCompletedCount;
  final int totalActivities;
  final bool isCurrentUser;

  Student({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.xp,
    required this.level,
    required this.rank,
    required this.habitsCompletedCount,
    required this.challengesCompletedCount,
    required this.totalActivities,
    required this.isCurrentUser,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      xp: json['xp'],
      level: json['level'],
      rank: json['rank'],
      habitsCompletedCount: json['habits_completed_count'],
      challengesCompletedCount: json['challenges_completed_count'],
      totalActivities: json['total_activities'],
      isCurrentUser: json['is_current_user'],
    );
  }
}

class StudentDetail {
  final int id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? email;
  final int xp;
  final int level;
  final int ranking;
  final int totalStudents;
  final bool isCurrentUser;
  final StudentStatistics statistics;
  final List<RecentHabit> recentHabits;
  final List<RecentChallenge> recentChallenges;

  StudentDetail({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.email,
    required this.xp,
    required this.level,
    required this.ranking,
    required this.totalStudents,
    required this.isCurrentUser,
    required this.statistics,
    required this.recentHabits,
    required this.recentChallenges,
  });

  factory StudentDetail.fromJson(Map<String, dynamic> json) {
    return StudentDetail(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      email: json['email'],
      xp: json['xp'],
      level: json['level'],
      ranking: json['ranking'],
      totalStudents: json['total_students'],
      isCurrentUser: json['is_current_user'],
      statistics: StudentStatistics.fromJson(json['statistics']),
      recentHabits: (json['recent_habits'] as List)
          .map((item) => RecentHabit.fromJson(item))
          .toList(),
      recentChallenges: (json['recent_challenges'] as List)
          .map((item) => RecentChallenge.fromJson(item))
          .toList(),
    );
  }
}

class StudentStatistics {
  final int habitsCompleted;
  final int challengesCompleted;
  final int reflectionStreak;
  final int totalActivities;
  final int xpFromHabits;
  final int xpFromChallenges;
  final double habitCompletionRate;
  final double challengeCompletionRate;
  final double averageCompletionRate;

  StudentStatistics({
    required this.habitsCompleted,
    required this.challengesCompleted,
    required this.reflectionStreak,
    required this.totalActivities,
    required this.xpFromHabits,
    required this.xpFromChallenges,
    required this.habitCompletionRate,
    required this.challengeCompletionRate,
    required this.averageCompletionRate,
  });

  factory StudentStatistics.fromJson(Map<String, dynamic> json) {
    return StudentStatistics(
      habitsCompleted: json['habits_completed'],
      challengesCompleted: json['challenges_completed'],
      reflectionStreak: json['reflection_streak'],
      totalActivities: json['total_activities'],
      xpFromHabits: json['xp_from_habits'],
      xpFromChallenges: json['xp_from_challenges'],
      habitCompletionRate: double.parse(json['habit_completion_rate'].toString()),
      challengeCompletionRate: double.parse(json['challenge_completion_rate'].toString()),
      averageCompletionRate: double.parse(json['average_completion_rate'].toString()),
    );
  }
}

class RecentHabit {
  final int id;
  final String title;
  final String dateCompleted;
  final String dailyStatus;
  final String dailyStatusText;
  final int totalStreak;
  final int xpReward;

  RecentHabit({
    required this.id,
    required this.title,
    required this.dateCompleted,
    required this.dailyStatus,
    required this.dailyStatusText,
    required this.totalStreak,
    required this.xpReward,
  });

  factory RecentHabit.fromJson(Map<String, dynamic> json) {
    return RecentHabit(
      id: json['id'],
      title: json['title'],
      dateCompleted: json['date_completed'],
      dailyStatus: json['daily_status'],
      dailyStatusText: json['daily_status_text'],
      totalStreak: json['total_streak'],
      xpReward: json['xp_reward'],
    );
  }
}

class RecentChallenge {
  final int id;
  final String title;
  final int xpReward;
  final String? completedAt;
  final String? proofUrl;

  RecentChallenge({
    required this.id,
    required this.title,
    required this.xpReward,
    this.completedAt,
    this.proofUrl,
  });

  factory RecentChallenge.fromJson(Map<String, dynamic> json) {
    return RecentChallenge(
      id: json['id'],
      title: json['title'],
      xpReward: json['xp_reward'],
      completedAt: json['completed_at'],
      proofUrl: json['proof_url'],
    );
  }
}

class LeaderboardResponse {
  final List<Student> students;
  final int? currentStudentRank;
  final ClassInfo classInfo;
  final CurrentStudent currentStudent;

  LeaderboardResponse({
    required this.students,
    this.currentStudentRank,
    required this.classInfo,
    required this.currentStudent,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LeaderboardResponse(
      students: (data['students'] as List)
          .map((item) => Student.fromJson(item))
          .toList(),
      currentStudentRank: data['current_student_rank'],
      classInfo: ClassInfo.fromJson(data['kelas_info']),
      currentStudent: CurrentStudent.fromJson(data['current_student']),
    );
  }
}

class ClassInfo {
  final int id;
  final String nama;
  final int totalStudents;

  ClassInfo({
    required this.id,
    required this.nama,
    required this.totalStudents,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'],
      nama: json['nama'],
      totalStudents: json['total_students'],
    );
  }
}

class CurrentStudent {
  final int id;
  final String name;
  final int xp;
  final int level;

  CurrentStudent({
    required this.id,
    required this.name,
    required this.xp,
    required this.level,
  });

  factory CurrentStudent.fromJson(Map<String, dynamic> json) {
    return CurrentStudent(
      id: json['id'],
      name: json['name'],
      xp: json['xp'],
      level: json['level'],
    );
  }
}