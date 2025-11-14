import 'package:flutter/material.dart';
import 'package:keep_it_grow/screens/student/habit_detail_screen.dart';
import 'package:keep_it_grow/screens/student/create_habit_screen.dart';
import '../../models/user_model.dart';
import '../../services/habits_service.dart';

class HabitsScreen extends StatefulWidget {
  final UserModel user;

  const HabitsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HabitsScreenState createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<dynamic> _habits = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<int, bool> _updatingHabits = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await HabitsService.getStudentHabits();
      setState(() {
        _habits = data['data'] ?? [];
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

  Future<void> _joinHabit(int habitId) async {
    setState(() {
      _updatingHabits[habitId] = true;
    });

    try {
      await HabitsService.joinHabit(habitId);

      // Update local state
      setState(() {
        final index = _habits.indexWhere((habit) => habit['id'] == habitId);
        if (index != -1) {
          _habits[index]['today_log'] = {
            'status': 'joined',
            'date': DateTime.now().toIso8601String().split('T')[0],
          };
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil bergabung dengan habit!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal bergabung dengan habit: $e'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    } finally {
      setState(() {
        _updatingHabits.remove(habitId);
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
                  "Habits Saya",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Kelola kebiasaan baik harian Anda",
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
              Icons.checklist_rounded,
              size: 30,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final completedToday = _habits
        .where((habit) => (habit['today_log']?['status'] ?? 'not_joined') == 'completed')
        .length;
    final submittedToday = _habits
        .where((habit) => (habit['today_log']?['status'] ?? 'not_joined') == 'submitted')
        .length;
    final joinedToday = _habits
        .where((habit) => (habit['today_log']?['status'] ?? 'not_joined') == 'joined')
        .length;
    
    final totalHabits = _habits.length;
    final progress = totalHabits > 0 ? (completedToday / totalHabits) * 100 : 0;
    
    final totalCompletedAllTime = _habits.fold<int>(
      0,
      (int sum, habit) => sum + ((habit['user_progress']?['completed_logs'] ?? 0) as int),
    );

    final totalXPEarned = _habits.fold<int>(
      0,
      (int sum, habit) {
        final completedLogs = (habit['user_progress']?['completed_logs'] ?? 0) as int;
        final xpReward = (habit['xp_reward'] ?? 0) as int;
        return sum + (completedLogs * xpReward);
      },
    );

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                "$totalHabits",
                "Total Habits",
                Icons.list_alt,
                Color(0xFF3B82F6),
              ),
              _buildStatItem(
                "$completedToday",
                "Selesai",
                Icons.check_circle,
                Color(0xFF10B981),
              ),
              _buildStatItem(
                "$totalXPEarned",
                "Total XP",
                Icons.auto_awesome,
                Color(0xFFF59E0B),
              ),
            ],
          ),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress Hari Ini",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${progress.toStringAsFixed(0)}%",
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "$completedToday selesai • $submittedToday menunggu • $joinedToday bergabung",
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ],
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

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'growth':
      case 'self awareness':
        return '🌱';
      case 'health':
      case 'fitness':
        return '💪';
      case 'study':
      case 'learning':
        return '📚';
      case 'morning':
        return '☀️';
      case 'evening':
        return '🌙';
      case 'productivity':
        return '⚡';
      case 'mindfulness':
        return '🧘';
      default:
        return '✅';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'growth':
      case 'self awareness':
        return Color(0xFF10B981);
      case 'health':
      case 'fitness':
        return Color(0xFFEF4444);
      case 'study':
      case 'learning':
        return Color(0xFF3B82F6);
      case 'morning':
        return Color(0xFFF59E0B);
      case 'evening':
        return Color(0xFF8B5CF6);
      case 'productivity':
        return Color(0xFF8B5CF6);
      case 'mindfulness':
        return Color(0xFFEC4899);
      default:
        return Color(0xFF6B7280);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Color(0xFF10B981);
      case 'submitted':
        return Color(0xFF3B82F6);
      case 'joined':
        return Color(0xFFF59E0B);
      default:
        return Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'submitted':
        return 'Menunggu';
      case 'joined':
        return 'Bergabung';
      default:
        return 'Belum';
    }
  }

  String _getPeriodText(String period) {
    switch (period) {
      case 'daily':
        return 'Harian';
      case 'weekly':
        return 'Mingguan';
      default:
        return period;
    }
  }

  Widget _buildHabitCard(Map<String, dynamic> habit) {
    final id = habit['id'] ?? 0;
    final title = habit['title'] ?? 'Habit';
    final description = habit['description'] ?? '';
    final category = habit['category'] ?? 'General';
    final period = habit['period'] ?? 'daily';
    final type = habit['type'] ?? 'self';
    final xpReward = habit['xp_reward'] ?? 0;
    
    final userProgress = habit['user_progress'] ?? {};
    final completedLogs = userProgress['completed_logs'] ?? 0;
    
    final todayStatus = habit['today_log']?['status'] ?? 'not_joined';
    final isUpdating = _updatingHabits[id] == true;
    final categoryIcon = _getCategoryIcon(category);
    final categoryColor = _getCategoryColor(category);
    final statusColor = _getStatusColor(todayStatus);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: categoryColor, width: 2),
          ),
          child: Center(
            child: isUpdating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(categoryIcon, style: TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
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
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPeriodText(period),
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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
                _getStatusText(todayStatus),
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
              builder: (context) => HabitDetailScreen(
                user: widget.user,
                habitId: id,
              ),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadHabits();
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
          Icon(Icons.checklist_rounded, size: 80, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            "Belum ada habits",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Mulai tambahkan habits pertama Anda",
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateHabitScreen(user: widget.user),
                ),
              ).then((refresh) {
                if (refresh == true) {
                  _loadHabits();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Tambah Habit Pertama'),
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
          'My Habits',
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
                        'Gagal memuat habits',
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
                        onPressed: _loadHabits,
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
                  onRefresh: _loadHabits,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildHeader(),
                        SizedBox(height: 24),
                        _buildStatsCard(),
                        SizedBox(height: 24),
                        _habits.isEmpty
                            ? _buildEmptyState()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Semua Habits",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Column(
                                    children: _habits.map<Widget>((habit) {
                                      return _buildHabitCard(habit);
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
              builder: (context) => CreateHabitScreen(user: widget.user),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadHabits();
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