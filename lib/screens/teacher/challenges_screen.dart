import 'package:flutter/material.dart';
import 'package:keep_it_grow/screens/teacher/challenge_detail_screen.dart';
import '../../models/user_model.dart';
import '../../services/teacher/challenge_service.dart';

class TeacherChallengesScreen extends StatefulWidget {
  final UserModel user;

  const TeacherChallengesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _TeacherChallengesScreenState createState() => _TeacherChallengesScreenState();
}

class _TeacherChallengesScreenState extends State<TeacherChallengesScreen> {
  List<dynamic> _challenges = [];
  Map<String, dynamic>? _kelasInfo;
  bool _isLoading = true;
  String _errorMessage = '';
  int _waitingValidationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final challengesData = await TeacherChallengeService.getChallenges();
      final waitingData = await TeacherChallengeService.getWaitingValidation();

      if (mounted) {
        setState(() {
          _challenges = challengesData['data']['challenges'] ?? [];
          _kelasInfo = challengesData['data']['kelas_info'];
          _waitingValidationCount = waitingData['data']['count'] ?? 0;
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

  void _navigateToDetail(int challengeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherChallengeDetailScreen(
          user: widget.user,
          challengeId: challengeId,
        ),
      ),
    );
  }

  void _navigateToWaitingValidation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WaitingValidationScreen(user: widget.user),
      ),
    );
  }

  Widget _buildHeader() {
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
                  "Challenges Kelas",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Kelola challenges siswa di kelas Anda",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Color(0xFF3B82F6), width: 2),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 30,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalChallenges = _challenges.length;
    final totalParticipants = _challenges.fold<int>(0, (sum, challenge) => sum + ((challenge['total_participants'] ?? 0) as int));
    final totalCompleted = _challenges.fold<int>(0, (sum, challenge) => sum + ((challenge['completed_count'] ?? 0) as int));
    final totalSubmitted = _challenges.fold<int>(0, (sum, challenge) => sum + ((challenge['submitted_count'] ?? 0) as int));

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            "$totalChallenges",
            "Total",
            Icons.flag,
            Color(0xFF3B82F6),
          ),
          _buildStatItem(
            "$totalCompleted",
            "Selesai",
            Icons.check_circle,
            Color(0xFF10B981),
          ),
          _buildStatItem(
            "$totalSubmitted",
            "Validasi",
            Icons.pending_actions,
            Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Challenges Kelas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        actions: [
          if (_waitingValidationCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.task_alt),
                  onPressed: _navigateToWaitingValidation,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_waitingValidationCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
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
                        'Gagal memuat challenges',
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
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildHeader(),
                        SizedBox(height: 24),
                        _buildStatsCard(),
                        SizedBox(height: 24),
                        _buildContent(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Class Info
        if (_kelasInfo != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                  '${_challenges.length} Challenges',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 16),

        // Challenges List
        _challenges.isEmpty
            ? _buildEmptyState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Semua Challenges",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: _challenges.map<Widget>((challenge) {
                      return _buildChallengeCard(challenge);
                    }).toList(),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, size: 80, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            "Belum ada challenges",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Belum ada challenges yang dibuat untuk kelas ini",
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(challenge['id']),
        borderRadius: BorderRadius.circular(12),
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
                      color: Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('🏆', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge['title'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          challenge['category'] ?? '',
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
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress Kelas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '${challenge['progress_percentage']}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: challenge['progress_percentage'] / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF34D399)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Stats Row
              Row(
                children: [
                  _buildStatItem(
                    '${challenge['total_participants']}',
                    'Peserta',
                    Icons.people,
                    Color(0xFF3B82F6),
                  ),
                  SizedBox(width: 16),
                  _buildStatItem(
                    '${challenge['completed_count']}',
                    'Selesai',
                    Icons.task_alt,
                    Color(0xFF10B981),
                  ),
                  SizedBox(width: 16),
                  _buildStatItem(
                    '${challenge['submitted_count']}',
                    'Validasi',
                    Icons.pending_actions,
                    Color(0xFFF59E0B),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${challenge['xp_reward']} XP',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${challenge['days_remaining']} hari lagi',
                    style: TextStyle(
                      color: challenge['days_remaining'] <= 3 ? Color(0xFFEF4444) : Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// Temporary screen for waiting validation
class _WaitingValidationScreen extends StatelessWidget {
  final UserModel user;

  const _WaitingValidationScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validasi Challenge'),
      ),
      body: Center(
        child: Text('Screen validasi challenge akan diimplementasi'),
      ),
    );
  }
}