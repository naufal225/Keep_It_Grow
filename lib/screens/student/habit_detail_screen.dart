import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_it_grow/screens/student/create_habit_screen.dart';
import '../../models/user_model.dart';
import '../../services/habits_service.dart';

class HabitDetailScreen extends StatefulWidget {
  final UserModel user;
  final int habitId;

  const HabitDetailScreen({Key? key, required this.user, required this.habitId})
    : super(key: key);

  @override
  _HabitDetailScreenState createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  Map<String, dynamic>? _habit;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadHabitDetail();
  }

  Future<void> _loadHabitDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await HabitsService.getHabitDetail(widget.habitId);
      setState(() {
        _habit = data['data'];
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

  Future<void> _joinHabit() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await HabitsService.joinHabit(widget.habitId);

      // Update local state
      setState(() {
        _habit!['today_log'] = {
          'status': 'joined',
          'date': DateTime.now().toIso8601String().split('T')[0],
        };
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
        _isUpdating = false;
      });
    }
  }

  Future<void> _submitProof() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _isUpdating = true;
      });

      try {
        await HabitsService.submitProof(
          widget.habitId,
          image.path,
          'Bukti penyelesaian habit', // Default note
        );

        // Update local state
        setState(() {
          _habit!['today_log'] = {
            'status': 'submitted',
            'proof_url': 'uploaded', // Placeholder
            'date': DateTime.now().toIso8601String().split('T')[0],
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bukti berhasil dikirim, menunggu verifikasi!'),
            backgroundColor: Color(0xFF3B82F6),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim bukti: $e'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Habit'),
        content: Text('Apakah Anda yakin ingin menghapus habit ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('HAPUS'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await HabitsService.deleteHabit(widget.habitId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habit berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus habit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHeaderCard() {
    final categoryColor = _getCategoryColor(_habit!['category']);
    final todayStatus = _habit!['today_log']?['status'] ?? 'not_joined';

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: categoryColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    _getCategoryIcon(_habit!['category']),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _habit!['title'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _habit!['category'],
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getPeriodText(_habit!['period']),
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
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${_habit!['xp_reward']} XP',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            _habit!['description'],
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(todayStatus),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(todayStatus),
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  _getStatusText(todayStatus),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final userProgress = _habit!['user_progress'] ?? {};
    final completedLogs = userProgress['completed_logs'] ?? 0;
    final submittedLogs = userProgress['submitted_logs'] ?? 0;
    final streak = userProgress['streak'] ?? 0;
    final completionRate = userProgress['completion_rate'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Selesai',
            '$completedLogs',
            Icons.check_circle,
            Color(0xFF10B981),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Menunggu',
            '$submittedLogs',
            Icons.schedule,
            Color(0xFF3B82F6),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Success Rate',
            '$completionRate%',
            Icons.trending_up,
            Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final userProgress = _habit!['user_progress'] ?? {};
    final completionRate = userProgress['completion_rate'] ?? 0;
    final completedLogs = userProgress['completed_logs'] ?? 0;
    final totalLogs = userProgress['total_logs'] ?? 0;

    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),

          // Completion Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tingkat Penyelesaian',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
              Text(
                '$completionRate%',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionRate / 100,
            backgroundColor: Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 8),
          Text(
            '$completedLogs dari $totalLogs hari berhasil',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final isOwner = _habit!['is_owner'] == true;
    final isAssigned = _habit!['is_assigned_to_me'] == true;
    final type = _habit!['type'];

    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'Informasi Habit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            'Periode',
            _getPeriodText(_habit!['period']),
            Icons.calendar_today,
          ),
          _buildDetailRow('Tipe', _getTypeText(type), Icons.category),
          _buildDetailRow(
            'XP Reward',
            '+${_habit!['xp_reward']} XP',
            Icons.auto_awesome,
          ),
          if (isAssigned && _habit!['assigned_by_name'] != null)
            _buildDetailRow(
              'Diassign oleh',
              _habit!['assigned_by_name'],
              Icons.person,
            ),
          if (isOwner)
            _buildDetailRow('Status', 'Habit Self Anda', Icons.verified),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Color(0xFF6B7280)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isOwner = _habit!['is_owner'] == true;
    final todayStatus = _habit!['today_log']?['status'] ?? 'not_joined';

    return Column(
      children: [
        // Status-based action button
        if (todayStatus == 'not_joined')
          _buildJoinButton()
        else if (todayStatus == 'joined')
          _buildSubmitButton()
        else if (todayStatus == 'submitted')
          _buildWaitingButton()
        else if (todayStatus == 'completed')
          _buildCompletedButton(),

        SizedBox(height: 12),

        // Owner actions
        if (isOwner)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUpdating
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateHabitScreen(
                                user: widget.user,
                                habit: _habit,
                              ),
                            ),
                          ).then((refresh) {
                            if (refresh == true) {
                              _loadHabitDetail();
                            }
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF3B82F6),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Color(0xFF3B82F6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUpdating ? null : _deleteHabit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.red),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, size: 18),
                      SizedBox(width: 8),
                      Text('Hapus'),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildJoinButton() {
    return ElevatedButton(
      onPressed: _isUpdating ? null : _joinHabit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isUpdating
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, size: 18),
                SizedBox(width: 8),
                Text('Mulai Habit Hari Ini'),
              ],
            ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isUpdating ? null : _submitProof,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isUpdating
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 18),
                SizedBox(width: 8),
                Text('Upload Bukti Penyelesaian'),
              ],
            ),
    );
  }

  Widget _buildWaitingButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Color(0xFFF59E0B)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bukti telah dikirim, menunggu verifikasi',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF10B981)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Habit telah diselesaikan hari ini! +${_habit!['xp_reward']} XP',
              style: TextStyle(
                color: Color(0xFF065F46),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'submitted':
        return Icons.schedule;
      case 'joined':
        return Icons.play_arrow;
      default:
        return Icons.circle_outlined;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'submitted':
        return 'Menunggu Verifikasi';
      case 'joined':
        return 'Sedang Dikerjakan';
      default:
        return 'Belum Dimulai';
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

  String _getTypeText(String type) {
    switch (type) {
      case 'self':
        return 'Habit Self';
      case 'assigned':
        return 'Habit Terassign';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Detail Habit',
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
                    'Gagal memuat detail habit',
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
                    onPressed: _loadHabitDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _habit == null
          ? Center(child: Text('Data habit tidak ditemukan'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  SizedBox(height: 20),
                  _buildStatsCards(),
                  SizedBox(height: 20),
                  _buildProgressSection(),
                  SizedBox(height: 20),
                  _buildDetailsSection(),
                  SizedBox(height: 20),
                  _buildActionButtons(),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
