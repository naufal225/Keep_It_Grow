import 'package:flutter/material.dart';
import 'package:keep_it_grow/screens/student/challenge_detail_screen.dart';
import 'package:keep_it_grow/screens/student/create_challenge_screen.dart';
import '../../models/user_model.dart';
import '../../services/challenges_service.dart';

class ChallengesScreen extends StatefulWidget {
  final UserModel user;

  const ChallengesScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<dynamic> _challenges = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await ChallengesService.getStudentChallenges();
      setState(() {
        _challenges = data['data'] ?? [];
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                  "Challenges",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Tantangan untuk berkembang lebih baik",
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
    final joinedChallenges = _challenges
        .where((challenge) => challenge['user_status'] == 'joined')
        .length;
    final completedChallenges = _challenges
        .where((challenge) => challenge['user_status'] == 'completed')
        .length;
    final totalChallenges = _challenges.length;

    // Hitung total XP dari challenges yang sudah completed saja
    final totalXPEarned = _challenges.fold<int>(0, (int sum, challenge) {
      if (challenge['user_status'] == 'completed') {
        final xpReward = (challenge['xp_reward'] ?? 0) as int;
        return sum + xpReward;
      }
      return sum;
    });

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
            "$completedChallenges",
            "Selesai",
            Icons.check_circle,
            Color(0xFF10B981),
          ),
          _buildStatItem(
            "$totalXPEarned",
            "XP Diperoleh",
            Icons.auto_awesome,
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'self discipline':
        return Color(0xFF10B981);
      case 'fitness':
        return Color(0xFFEF4444);
      case 'learning':
        return Color(0xFF3B82F6);
      case 'productivity':
        return Color(0xFFF59E0B);
      case 'mindfulness':
        return Color(0xFF8B5CF6);
      default:
        return Color(0xFF6B7280);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'joined':
        return Color(0xFF10B981);
      case 'completed':
        return Color(0xFF3B82F6);
      case 'available':
        return Color(0xFFF59E0B);
      default:
        return Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'joined':
        return 'Diikuti';
      case 'completed':
        return 'Selesai';
      case 'available':
        return 'Tersedia';
      default:
        return status;
    }
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    final id = challenge['id'] ?? 0;
    final title = challenge['title'] ?? 'Challenge';
    final description = challenge['description'] ?? '';
    final category = challenge['category'] ?? 'General';
    final xpReward = challenge['xp_reward'] ?? 0;
    final startDate = challenge['start_date'] ?? '';
    final endDate = challenge['end_date'] ?? '';
    final userStatus = challenge['user_status'] ?? 'available';
    final totalParticipants = challenge['total_participants'] ?? 0;

    final categoryColor = _getCategoryColor(category);
    final statusColor = _getStatusColor(userStatus);
    final isCompleted = userStatus == 'completed';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted
                ? categoryColor.withOpacity(0.1)
                : Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCompleted ? categoryColor : Color(0xFFE5E7EB),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.emoji_events_rounded,
              color: isCompleted ? categoryColor : Color(0xFF9CA3AF),
              size: 24,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
            decoration: isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
            ],
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(userStatus),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "+$xpReward XP",
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(userStatus),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChallengeDetailScreen(
                user: widget.user,
                challengeId: challenge['id'],
              ),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadChallenges();
            }
          });
        },
      ),
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
            "Mulai tambahkan challenge pertama Anda",
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateChallengeScreen(user: widget.user),
                ),
              ).then((refresh) {
                if (refresh == true) {
                  _loadChallenges();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Tambah Challenge Pertama'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Challenges',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
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
                    onPressed: _loadChallenges,
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
              onRefresh: _loadChallenges,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildStatsCard(),
                    SizedBox(height: 24),
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
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateChallengeScreen(user: widget.user),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadChallenges();
            }
          });
        },
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
