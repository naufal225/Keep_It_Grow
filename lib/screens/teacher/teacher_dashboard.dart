import 'package:flutter/material.dart';
import 'package:keep_it_grow/screens/teacher/challenges_screen.dart';
import 'package:keep_it_grow/screens/teacher/habits_screen.dart';
import 'package:keep_it_grow/screens/teacher/students_screen.dart';
import 'package:keep_it_grow/screens/teacher/profile_screen.dart';
import 'package:keep_it_grow/screens/placeholder_screen.dart';
import '../../models/user_model.dart';
import '../../services/teacher/dashboard_service.dart' as teacher_service;
import '../../services/teacher/challenge_service.dart';
import '../../services/teacher/habit_service.dart';

class TeacherDashboard extends StatefulWidget {
  final UserModel user;

  const TeacherDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _TeacherDashboardState createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
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
          onSeeAllStudents: () => _navigateToScreen(3),
          onSeeAllValidations: () => _navigateToScreen(1),
        ),
        TeacherChallengesScreen(user: widget.user),
        TeacherHabitsScreen(user: widget.user),
        TeacherStudentsScreen(user: widget.user),
        TeacherProfileScreen(user: widget.user),
      ];
    });
  }

  void _navigateToScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final data =
          await teacher_service.GuruDashboardService.getGuruDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
        _initializeScreens();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        _initializeScreens();
      }
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic>? dashboardData;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onSeeAllStudents;
  final VoidCallback onSeeAllValidations;

  const _DashboardContent({
    Key? key,
    required this.user,
    required this.dashboardData,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onSeeAllStudents,
    required this.onSeeAllValidations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading || dashboardData == null) {
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

    final stats = data['stats'] ?? [];
    final leaderboard = data['leaderboard'] ?? [];
    dynamic validasiCepatRaw = data['validasi_cepat'] ?? [];
    List<dynamic> validasiCepat = [];

    // Jika tipe-nya Map → ambil values
    if (validasiCepatRaw is Map) {
      validasiCepat = validasiCepatRaw.values.toList();
    }
    // Jika tipe-nya List → langsung pakai
    else if (validasiCepatRaw is List) {
      validasiCepat = validasiCepatRaw;
    }

    final kelasInfo = data['kelas_info'] ?? {};

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildHeaderSection(kelasInfo),
                  SizedBox(height: 24),
                  _buildStatsSection(stats),
                  SizedBox(height: 24),
                  _buildLeaderboardSection(leaderboard),
                  SizedBox(height: 24),
                  _buildValidasiCepatSection(context, validasiCepat),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> kelasInfo) {
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
                  "Selamat datang, ${user.name} 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Kelas ${kelasInfo['nama'] ?? ''}",
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
                child: Icon(Icons.school, size: 30, color: Color(0xFF3B82F6)),
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
                    "Guru",
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

  Widget _buildStatsSection(List<dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Statistik Kelas",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              stat['icon'] ?? '📊',
              stat['title'] ?? '',
              stat['value']?.toString() ?? '0',
              _getColorForStat(stat['color'] ?? ''),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, Color color) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForStat(String color) {
    switch (color) {
      case 'warning':
        return Color(0xFFF59E0B);
      case 'info':
        return Color(0xFF3B82F6);
      case 'success':
        return Color(0xFF10B981);
      default:
        return Color(0xFF6B7280);
    }
  }

  Widget _buildLeaderboardSection(List<dynamic> leaderboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Leaderboard Kelas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
            TextButton(
              onPressed: onSeeAllStudents,
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
        leaderboard.isEmpty
            ? _buildEmptyState('Belum ada data leaderboard', Icons.leaderboard)
            : Container(
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
                  children: leaderboard.asMap().entries.map((entry) {
                    final index = entry.key;
                    final student = entry.value;
                    return _buildLeaderboardItem(
                      student['medal'] ?? '🏅',
                      student['nama'] ?? '',
                      student['xp']?.toString() ?? '0',
                      student['level']?.toString() ?? '1',
                      index == leaderboard.length - 1,
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    String medal,
    String name,
    String xp,
    String level,
    bool isLast,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF9FAFB),
            ),
            child: Center(child: Text(medal, style: TextStyle(fontSize: 20))),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Level $level',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$xp XP',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidasiCepatSection(
    BuildContext context,
    List<dynamic> validasiCepat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Validasi Cepat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
            TextButton(
              onPressed: onSeeAllValidations,
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
        validasiCepat.isEmpty
            ? _buildEmptyState(
                'Tidak ada yang perlu divalidasi',
                Icons.task_alt,
              )
            : Column(
                children: validasiCepat.map<Widget>((item) {
                  return _buildValidasiItem(
                    context,
                    item['icon'] ?? '📝',
                    item['student_name'] ?? '',
                    item['activity_title'] ?? '',
                    item['date'] ?? '',
                    item['proof_url'] ?? '',
                    item['type'] ?? '',
                    item['id'] ?? 0,
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildValidasiItem(
    BuildContext context,
    String icon,
    String studentName,
    String activityTitle,
    String date,
    String proofUrl,
    String type,
    int id,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(icon, style: TextStyle(fontSize: 20)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '$activityTitle • $date',
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
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Lihat bukti
                      _showProofImage(context, proofUrl);
                    },
                    icon: Icon(Icons.visibility, size: 16),
                    label: Text('Lihat Bukti'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF3B82F6),
                      side: BorderSide(color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _handleApproveSubmission(context, type, id);
                    },
                    icon: Icon(Icons.check, size: 16),
                    label: Text('Setujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF10B981),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _handleRejectSubmission(context, type, id);
                    },
                    icon: Icon(Icons.close, size: 16),
                    label: Text('Tolak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showProofImage(BuildContext context, String proofUrl) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: proofUrl.isNotEmpty
          ? Image.network(
              _buildStorageUrl(proofUrl),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(20),
                child: const Text('Gagal memuat gambar bukti'),
              ),
            )
          : Container(
              padding: EdgeInsets.all(20),
              child: Text('Bukti tidak tersedia'),
            ),
    ),
  );
}

Future<void> _handleApproveSubmission(
  BuildContext context,
  String type,
  int id,
) async {
  try {
    Map<String, dynamic> res;
    if (type == 'challenge') {
      res = await TeacherChallengeService.approveSubmission(id);
    } else if (type == 'habit') {
      res = await TeacherHabitService.approveSubmission(id);
    } else {
      throw Exception('Tipe tidak dikenal: $type');
    }

    final msg = res['message'] ?? 'Berhasil menyetujui.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    // Refresh dashboard
    final state = context.findAncestorStateOfType<_TeacherDashboardState>();
    state?._loadDashboardData();
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gagal menyetujui: $e')));
  }
}

Future<void> _handleRejectSubmission(
  BuildContext context,
  String type,
  int id,
) async {
  try {
    Map<String, dynamic> res;
    if (type == 'challenge') {
      res = await TeacherChallengeService.rejectSubmission(id);
    } else if (type == 'habit') {
      res = await TeacherHabitService.rejectSubmission(id);
    } else {
      throw Exception('Tipe tidak dikenal: $type');
    }

    final msg = res['message'] ?? 'Berhasil menolak.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    // Refresh dashboard
    final state = context.findAncestorStateOfType<_TeacherDashboardState>();
    state?._loadDashboardData();
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Gagal menolak: $e')));
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

// Helper untuk merakit URL storage dari path relatif
String _buildStorageUrl(String url) {
  if (url.isEmpty) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  const String base = 'http://10.0.2.2:8000/storage/';
  if (url.startsWith('/')) {
    return base + url.substring(1);
  }
  return base + url;
}
