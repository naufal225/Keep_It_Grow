import 'package:flutter/material.dart';
import '../../services/student/student_service.dart';
import 'package:keep_it_grow/models/student_models.dart';
import '../../services/auth_service.dart';
import '../../services/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<LeaderboardResponse> _leaderboardFuture;
  final StudentService _studentService = StudentService();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final token = await AuthService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi telah berakhir. Silakan login kembali.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _leaderboardFuture = _studentService.getLeaderboard().then((response) {
        return LeaderboardResponse.fromJson(response);
      });
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadLeaderboard();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    String rankText;
    Color textColor;
    String? medal;

    switch (rank) {
      case 1:
        badgeColor = Color(0xFFFFD700); // Gold
        rankText = '1';
        textColor = Colors.white;
        medal = '🥇';
        break;
      case 2:
        badgeColor = Color(0xFFC0C0C0); // Silver
        rankText = '2';
        textColor = Colors.white;
        medal = '🥈';
        break;
      case 3:
        badgeColor = Color(0xFFCD7F32); // Bronze
        rankText = '3';
        textColor = Colors.white;
        medal = '🥉';
        break;
      default:
        badgeColor = Color(0xFFF3F4F6);
        rankText = '$rank';
        textColor = Color(0xFF6B7280);
        medal = null;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: medal != null
            ? Text(
                medal,
                style: TextStyle(fontSize: 16),
              )
            : Text(
                rankText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildStudentCard(Student student, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: student.isCurrentUser 
          ? Color(0xFFEFF6FF) 
          : Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: _buildRankBadge(student.rank),
        title: Row(
          children: [
            // Student Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3F4F6),
              ),
              child: student.avatarUrl != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                        student.avatarUrl!.startsWith('http')
                            ? student.avatarUrl!
                            : ServiceConstants.storageBase + student.avatarUrl!,
                      ),
                    )
                  : Icon(Icons.person, color: Color(0xFF6B7280)),
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
                          student.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: student.isCurrentUser ? Color(0xFF3B82F6) : Color(0xFF111827),
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (student.isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Anda',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@${student.username}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8, left: 52), // Adjusted for avatar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Level ${student.level}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.bolt, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${student.xp} XP',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF3B82F6), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${student.totalActivities} aktivitas selesai',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFF3B82F6).withOpacity(0.2)),
          ),
          child: Text(
            '#${student.rank}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
        
      ),
    );
  }

  Widget _buildTopThreeStudents(List<Student> students) {
    if (students.length < 3) return SizedBox();

    final topThree = students.take(3).toList();
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEFCE8), Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TOP 3 SISWA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF92400E),
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Second Place
              _buildTopStudentCard(topThree[1], 2, Color(0xFFC0C0C0)),
              
              // First Place
              _buildTopStudentCard(topThree[0], 1, Color(0xFFFFD700)),
              
              // Third Place
              _buildTopStudentCard(topThree[2], 3, Color(0xFFCD7F32)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopStudentCard(Student student, int rank, Color medalColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            // Medal Background
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: medalColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            // Student Avatar
            Positioned(
              bottom: -10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: student.avatarUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          student.avatarUrl!.startsWith('http')
                              ? student.avatarUrl!
                              : ServiceConstants.storageBase + student.avatarUrl!,
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Color(0xFFF3F4F6),
                        child: Icon(Icons.person, color: Color(0xFF6B7280), size: 20),
                      ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          width: 80,
          child: Column(
            children: [
              Text(
                student.name.split(' ').first, // First name only
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '${student.xp} XP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF065F46),
                ),
              ),
              Text(
                'Level ${student.level}',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ClassInfo classInfo, CurrentStudent currentStudent, int? currentRank) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Leaderboard Kelas',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${classInfo.nama} • ${classInfo.totalStudents} Siswa',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          if (currentRank != null)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Ranking Anda',
                      '#$currentRank',
                      Icons.leaderboard,
                      Color(0xFF3B82F6),
                    ),
                    _buildStatItem(
                      'Level',
                      '${currentStudent.level}',
                      Icons.star,
                      Color(0xFF10B981),
                    ),
                    _buildStatItem(
                      'Total XP',
                      '${currentStudent.xp}',
                      Icons.bolt,
                      Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat leaderboard...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, 
                color: Color(0xFF6B7280)
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadLeaderboard,
              icon: Icon(Icons.refresh, size: 20),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(LeaderboardResponse data) {
    return Column(
      children: [
        _buildHeader(data.classInfo, data.currentStudent, data.currentStudentRank),
        if (data.students.length >= 3) 
          _buildTopThreeStudents(data.students),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            backgroundColor: Colors.white,
            color: Color(0xFF3B82F6),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.students.length,
              itemBuilder: (context, index) {
                return _buildStudentCard(data.students[index], context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.leaderboard_outlined,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Leaderboard akan terisi ketika siswa mulai mengumpulkan XP',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, 
                color: Color(0xFF6B7280)
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: FutureBuilder<LeaderboardResponse>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            if (data.students.isEmpty) {
              return _buildEmptyState();
            }
            return _buildSuccessState(data);
          } else {
            return _buildErrorState('Tidak ada data yang dapat ditampilkan');
          }
        },
      ),
      floatingActionButton: _isRefreshing
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: Color(0xFF3B82F6),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : null,
    );
  }
}