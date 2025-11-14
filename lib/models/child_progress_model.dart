class ChildProgress {
  final int id;
  final String name;
  final String className;
  final int level;
  final int xp;
  final int xpForNextLevel;
  final double xpProgress;
  final String? avatarUrl;
  final List<WeeklyActivity> weeklyActivity;
  final WeeklySummary summary;

  ChildProgress({
    required this.id,
    required this.name,
    required this.className,
    required this.level,
    required this.xp,
    required this.xpForNextLevel,
    required this.xpProgress,
    this.avatarUrl,
    required this.weeklyActivity,
    required this.summary,
  });

  factory ChildProgress.fromJson(Map<String, dynamic> json) {
    final childData = json['child'] ?? {};

    return ChildProgress(
      id: childData['id'] ?? 0,
      name: childData['name'] ?? '',
      className: childData['class'] ?? 'Belum ada kelas',
      level: childData['level'] ?? 1,
      xp: childData['xp'] ?? 0,
      xpForNextLevel: childData['xp_for_next_level'] ?? 1000,
      xpProgress: (childData['xp_progress'] ?? 0).toDouble(),
      avatarUrl: childData['avatar_url'],
      weeklyActivity: (json['weekly_activity'] as List? ?? [])
          .map((activity) => WeeklyActivity.fromJson(activity))
          .toList(),
      summary: WeeklySummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class ChildBasicInfo {
  final int id;
  final String name;
  final String className;
  final int level;
  final int xp;
  final String? avatarUrl;

  ChildBasicInfo({
    required this.id,
    required this.name,
    required this.className,
    required this.level,
    required this.xp,
    this.avatarUrl,
  });

  factory ChildBasicInfo.fromJson(Map<String, dynamic> json) {
    print('Parsing ChildBasicInfo JSON: $json'); // Debug print

    return ChildBasicInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      className:
          json['class'] ??
          'Belum ada kelas', // PERBAIKAN: 'class' bukan 'className'
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      avatarUrl: json['avatar_url'],
    );
  }
}

class WeeklyActivity {
  final String date;
  final String day;
  final String dayShort;
  final int habitCount;
  final int challengeCount;
  final int reflectionCount;
  final int totalActivity;
  final double activityPercentage;

  WeeklyActivity({
    required this.date,
    required this.day,
    required this.dayShort,
    required this.habitCount,
    required this.challengeCount,
    required this.reflectionCount,
    required this.totalActivity,
    required this.activityPercentage,
  });

  factory WeeklyActivity.fromJson(Map<String, dynamic> json) {
    return WeeklyActivity(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      dayShort: json['day_short'] ?? '',
      habitCount: json['habit_count'] ?? 0,
      challengeCount: json['challenge_count'] ?? 0,
      reflectionCount: json['reflection_count'] ?? 0,
      totalActivity: json['total_activity'] ?? 0,
      activityPercentage: (json['activity_percentage'] ?? 0).toDouble(),
    );
  }
}

class WeeklySummary {
  final int habitsCompleted;
  final int habitsExpected;
  final double habitsPercentage;
  final int challengesCompleted;
  final int reflectionsCreated;
  final int totalXpEarned;

  WeeklySummary({
    required this.habitsCompleted,
    required this.habitsExpected,
    required this.habitsPercentage,
    required this.challengesCompleted,
    required this.reflectionsCreated,
    required this.totalXpEarned,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      habitsCompleted: json['habits_completed'] ?? 0,
      habitsExpected: json['habits_expected'] ?? 0,
      habitsPercentage: (json['habits_percentage'] ?? 0).toDouble(),
      challengesCompleted: json['challenges_completed'] ?? 0,
      reflectionsCreated: json['reflections_created'] ?? 0,
      totalXpEarned: json['total_xp_earned'] ?? 0,
    );
  }
}
