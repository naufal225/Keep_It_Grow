import 'package:flutter/material.dart';
import 'package:keep_it_grow/services/constants.dart';
import '../../models/user_model.dart';
import '../../services/teacher/student_service.dart';
import 'student_detail_screen.dart';

class TeacherStudentsScreen extends StatefulWidget {
  final UserModel user;

  const TeacherStudentsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _TeacherStudentsScreenState createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  List<dynamic> _students = [];
  Map<String, dynamic>? _kelasInfo;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final data = await TeacherStudentService.getStudents();
      if (mounted) {
        setState(() {
          _students = data['data']['students'] ?? [];
          _kelasInfo = data['data']['kelas_info'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDetail(int studentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TeacherStudentDetailScreen(user: widget.user, studentId: studentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Daftar Siswa',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadStudents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
                  SizedBox(height: 16),
                  Text(
                    'Gagal memuat data siswa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Color(0xFF6B7280)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadStudents,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Header Info
        if (_kelasInfo != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.school, color: Color(0xFF3B82F6)),
                SizedBox(width: 8),
                Text(
                  'Kelas ${_kelasInfo!['nama']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Spacer(),
                Text(
                  '${_students.length} Siswa',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        SizedBox(height: 8),

        // Students List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadStudents,
            child: _students.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada siswa di kelas',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return _buildStudentCard(student, index);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    final medal = index < 3 ? ['🥇', '🥈', '🥉'][index] : '${student['rank']}';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(student['id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank Medal
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankColor(index),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    medal,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _getRankTextColor(index),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),

              // Student Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3F4F6),
                ),
                child: student['avatar_url'] != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          student['avatar_url'].startsWith('http')
                              ? student['avatar_url']
                              : ServiceConstants.storageBase +
                                    student['avatar_url'],
                        ),
                      )
                    : Icon(Icons.person, color: Color(0xFF6B7280)),
              ),
              SizedBox(width: 12),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      student['username'] ?? '',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildMiniStat('Level', '${student['level']}'),
                        SizedBox(width: 12),
                        _buildMiniStat('XP', '${student['xp']}'),
                      ],
                    ),
                  ],
                ),
              ),

              // Activities Count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${student['total_activities']} Aktifitas',
                      style: TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${student['habits_completed_count']} Habits',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                  Text(
                    '${student['challenges_completed_count']} Challenges',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Color(0xFFFFD700); // Gold
      case 1:
        return Color(0xFFC0C0C0); // Silver
      case 2:
        return Color(0xFFCD7F32); // Bronze
      default:
        return Color(0xFFF3F4F6); // Gray
    }
  }

  Color _getRankTextColor(int index) {
    return index < 3 ? Colors.white : Color(0xFF6B7280);
  }
}
