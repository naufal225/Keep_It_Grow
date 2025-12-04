// screens/student_dashboard.dart
import 'package:flutter/material.dart';
import 'package:keep_it_grow/screens/student/challenges_screen.dart';
import 'package:keep_it_grow/screens/student/habits_screen.dart';
import 'package:keep_it_grow/screens/student/habit_detail_screen.dart';
import 'package:keep_it_grow/screens/student/challenge_detail_screen.dart';
import 'package:keep_it_grow/screens/placeholder_screen.dart';
import 'package:keep_it_grow/screens/student/leaderboard_screen.dart';
import 'package:keep_it_grow/screens/student/profile_screen.dart';
import 'package:keep_it_grow/screens/student/reflection_screen.dart';
import 'package:keep_it_grow/screens/student/parent_support_detail_screen.dart';
import 'package:keep_it_grow/screens/student/redeem_reward_screen.dart';
import '../../models/user_model.dart';
import 'package:keep_it_grow/models/student_parent_support_models.dart';
import '../../services/dashboard_service.dart';
import 'package:keep_it_grow/services/student/parent_support_service.dart';
// ... import lainnya
import 'package:keep_it_grow/screens/student/parent_support_screen.dart'; // IMPORT BARU

class StudentDashboard extends StatefulWidget {
  final UserModel user;

  const StudentDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _initializeScreens() {
    setState(() {
      _screens = [
        _DashboardContent(
          user: widget.user,
          dashboardData: _dashboardData,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onRefresh: _loadDashboardData,
          onSeeMoreHabits: () => _navigateToScreen(2),
          onSeeMoreChallenges: () => _navigateToScreen(1),
          onSeeParentSupport: () => _navigateToParentSupport(), // TAMBAH INI
        ),
        ChallengesScreen(user: widget.user),
        HabitsScreen(user: widget.user),
        ReflectionScreen(user: widget.user),
        LeaderboardScreen(),
        StudentProfileScreen(initialUser: widget.user),
      ];
    });
  }

  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // METHOD BARU: Navigate ke Parent Support Screen
  void _navigateToParentSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentParentSupportScreen()),
    ).then((_) => _loadDashboardData());
  }

  // ... metode lainnya tetap sama
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await DashboardService.getStudentDashboard();
      _dashboardData = data;
    } catch (e) {
      _errorMessage = e.toString();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _initializeScreens();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_screens.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF3B82F6),
        unselectedItemColor: Color(0xFF6B7280),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

// PERBAIKI DASHBOARD CONTENT - TAMBAH PARAMETER onSeeParentSupport
// screens/student_dashboard.dart - BAGIAN 7
class _DashboardContent extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic>? dashboardData;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onSeeMoreHabits;
  final VoidCallback onSeeMoreChallenges;
  final VoidCallback onSeeParentSupport;

  const _DashboardContent({
    Key? key,
    required this.user,
    required this.dashboardData,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onSeeMoreHabits,
    required this.onSeeMoreChallenges,
    required this.onSeeParentSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: Text('Refresh')),
          ],
        ),
      );
    }

    final data = dashboardData?['data'];
    if (data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Data tidak valid'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: Text('Refresh')),
          ],
        ),
      );
    }

    final profile = data['profile'] ?? {};
    final stats = data['stats'] ?? {};
    final latestHabits = data['latest_habits'] ?? [];
    final latestChallenges = data['latest_challenges'] ?? [];
    final reflectionToday = data['reflection_today'] ?? {};
    final parentSupport = data['parent_support'] ?? {};

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildHeaderSection(profile),
                  SizedBox(height: 24),
                  _buildXpStreakCard(context, profile, stats),
                  SizedBox(height: 24),
                  _buildParentSupportSection(context, parentSupport),
                  SizedBox(height: 24),
                  _buildTodayTasksSection(context, latestHabits),
                  SizedBox(height: 24),
                  _buildActiveChallengesSection(context, latestChallenges),
                  SizedBox(height: 24),
                  _buildReflectionSection(reflectionToday),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // screens/student_dashboard.dart - BAGIAN 9
  Widget _buildNoParentConnectedState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom,
                size: 30,
                color: Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Belum Ada Orang Tua Terhubung',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Mintalah guru untuk menghubungkan akun dengan orang tua Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET BARU: Parent Support Section
  // screens/student_dashboard.dart - BAGIAN 8
  // screens/student_dashboard.dart - BAGIAN 8 (DIPERBAIKI)
  Widget _buildParentSupportSection(
    BuildContext context,
    dynamic parentSupportData,
  ) {
    // Konversi ke Map<String, dynamic> dengan safety check
    final Map<String, dynamic> supportData = _convertToMap(parentSupportData);

    final hasParent = supportData['has_parent'] ?? false;
    final hasSupport = supportData['has_support'] ?? false;
    final latestSupport = supportData['latest_support'];
    final unreadCount = supportData['unread_count'] ?? 0;
    final message = supportData['message'] ?? '';

    if (!hasParent) {
      return _buildNoParentConnectedState();
    }

    if (!hasSupport) {
      return _buildNoSupportMessageState(message);
    }

    return _buildActiveSupportSection(
      context,
      latestSupport,
      unreadCount,
      message,
    );
  }

  // Helper method untuk konversi tipe Map
  Map<String, dynamic> _convertToMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map<dynamic, dynamic>) {
      // Konversi Map<dynamic, dynamic> ke Map<String, dynamic>
      return data.map((key, value) => MapEntry(key.toString(), value));
    } else {
      // Return empty map jika data tidak valid
      return {};
    }
  }

  // screens/student_dashboard.dart - BAGIAN 11
  Widget _buildActiveSupportSection(
    BuildContext context,
    Map<String, dynamic>? latestSupport,
    int unreadCount,
    String message,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Dukungan Orang Tua",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
            TextButton(
              onPressed: onSeeParentSupport,
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Badge unread count
        if (unreadCount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFF59E0B)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
                SizedBox(width: 6),
                Text(
                  '$unreadCount pesan belum dibaca',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: unreadCount > 0 ? 12 : 0),

        // Preview pesan terbaru
        if (latestSupport != null)
          _buildParentSupportPreview(context, latestSupport),

        // CTA Button
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSeeParentSupport,
            icon: Icon(Icons.family_restroom, size: 20),
            label: Text('Baca Semua Pesan Dukungan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // screens/student_dashboard.dart - BAGIAN 10
  Widget _buildNoSupportMessageState(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom,
                size: 30,
                color: Color(0xFF10B981),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Orang Tua Siap Memberi Dukungan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8),
            Text(
              message.isNotEmpty
                  ? message
                  : 'Orang tua Anda siap memberikan motivasi dan dukungan!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSeeParentSupport,
                icon: Icon(Icons.family_restroom, size: 18),
                label: Text('Lihat Halaman Dukungan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk preview pesan dukungan
  Future<void> _openParentSupportDetail(
    BuildContext context,
    Map<String, dynamic> support,
  ) async {
    final parentSupport = StudentParentSupport.fromJson(_convertToMap(support));

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentSupportDetailScreen(
          parentSupport: parentSupport,
          onMarkAsRead: () async {
            if (parentSupport.id == 0) return;
            try {
              await ParentSupportService().markAsRead(parentSupport.id);
              onRefresh();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menandai pesan: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );

    onRefresh();
  }

  Widget _buildParentSupportPreview(
    BuildContext context,
    Map<String, dynamic> support,
  ) {
    final isRead = support['is_read'] ?? false;
    final parentName = support['parent_name'] ?? 'Orang Tua';
    final message = support['message'] ?? '';
    final timeAgo = support['time_ago'] ?? '';

    return InkWell(
      onTap: () => _openParentSupportDetail(context, support),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isRead ? Colors.white : Color(0xFFF0FDF4),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3F4F6),
                ),
                child: Icon(
                  Icons.family_restroom,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            parentName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Baru',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      message.length > 60
                          ? '${message.substring(0, 60)}...'
                          : message,
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk state kosong parent support
  Widget _buildEmptyParentSupportState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom,
                size: 30,
                color: Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Belum Ada Pesan Dukungan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Orang tua Anda akan mengirimkan pesan motivasi dan dukungan di sini',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSeeParentSupport,
                icon: Icon(Icons.family_restroom, size: 18),
                label: Text('Lihat Halaman Dukungan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... widget methods lainnya TETAP SAMA (tidak berubah)
  Widget _buildHeaderSection(Map<String, dynamic> profile) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, ${profile['name'] ?? user.name} 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  profile['message'] ?? "Keep growing every day!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF3B82F6), width: 2),
                ),
                child: Icon(Icons.person, size: 30, color: Color(0xFF3B82F6)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Lv. ${user.level} 🌱",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... widget methods lainnya TETAP SAMA
  Widget _buildXpStreakCard(
    BuildContext context,
    Map<String, dynamic> profile,
    Map<String, dynamic> stats,
  ) {
    final xp = profile['xp'] ?? user.xp;
    final streak = stats['streak'] ?? 0;
    final habitsDone = stats['habits_done'] ?? 0;
    final coins = profile['coin'] ?? user.coin;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildStatItem("$xp XP", Icons.auto_awesome, Color(0xFF3B82F6)),
              _buildStatItem(
                streak > 0 ? "$streak days" : "0 days",
                Icons.local_fire_department,
                streak > 0 ? Color(0xFFEF4444) : Color(0xFF9CA3AF),
              ),
              _buildStatItem(
                "$habitsDone Habits",
                Icons.check_circle,
                Color(0xFF10B981),
              ),
              _buildStatItem(
                "$coins Koin",
                Icons.monetization_on,
                Color(0xFFF59E0B),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RedeemRewardScreen(user: user),
                  ),
                );
              },
              icon: Icon(Icons.card_giftcard),
              label: Text('Redeem Koin jadi Reward'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ... widget methods lainnya TETAP SAMA
  Widget _buildTodayTasksSection(
    BuildContext context,
    List<dynamic> latestHabits,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Habits",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
            TextButton(
              onPressed: onSeeMoreHabits,
              child: Text(
                'See More',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        latestHabits.isEmpty
            ? _buildEmptyState('No habits for today', Icons.checklist)
            : Column(
                children: latestHabits.map<Widget>((habit) {
                  return _buildTaskCard(
                    "📝",
                    habit['title'] ?? 'Habit',
                    habit['is_done_today'] ?? false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(
                            user: user,
                            habitId: habit['id'],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildTaskCard(
    String emoji,
    String title,
    bool completed, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: completed
                ? Color(0xFF10B981).withOpacity(0.1)
                : Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(emoji, style: TextStyle(fontSize: 20))),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
            decoration: completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: completed ? Color(0xFF10B981) : Color(0xFFF59E0B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            completed ? "✅ Done" : "⏳ Pending",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChallengesSection(
    BuildContext context,
    List<dynamic> latestChallenges,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Challenges",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
            TextButton(
              onPressed: onSeeMoreChallenges,
              child: Text(
                'See More',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        latestChallenges.isEmpty
            ? _buildEmptyState('No active challenges', Icons.emoji_events)
            : Container(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: latestChallenges.map<Widget>((challenge) {
                    return _buildChallengeCard(
                      "🏆",
                      challenge['title'] ?? 'Challenge',
                      "${challenge['xp_reward'] ?? 0} XP",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeDetailScreen(
                              user: user,
                              challengeId: challenge['id'],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildChallengeCard(
    String emoji,
    String title,
    String xpReward, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFFACC15).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFFACC15)),
              ),
              child: Text(
                "Reward: $xpReward",
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionSection(Map<String, dynamic> reflectionToday) {
    final status = reflectionToday['status'] ?? 'belum';
    final message = reflectionToday['message'] ?? '';

    if (status == 'belum') {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Reflection",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text("🤔", style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Belum ada refleksi hari ini",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          message.isNotEmpty
                              ? message
                              : "Yuk tulis refleksi hari ini agar tetap sadar diri 🌱",
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to reflections screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Tulis Refleksi'),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Reflection",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text("😊", style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Refleksi hari ini",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to view all reflections
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF3B82F6),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("View All Reflections"),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Color(0xFF9CA3AF)),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
