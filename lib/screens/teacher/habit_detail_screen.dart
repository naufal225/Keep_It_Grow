import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/teacher/habit_service.dart';

class TeacherHabitDetailScreen extends StatefulWidget {
  final UserModel user;
  final int habitId;

  const TeacherHabitDetailScreen({
    Key? key,
    required this.user,
    required this.habitId,
  }) : super(key: key);

  @override
  _TeacherHabitDetailScreenState createState() =>
      _TeacherHabitDetailScreenState();
}

class _TeacherHabitDetailScreenState extends State<TeacherHabitDetailScreen> {
  Map<String, dynamic>? _habitData;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isVerifying = false;
  int? _verifyingLogId;

  @override
  void initState() {
    super.initState();
    _loadHabitDetail();
  }

  Future<void> _loadHabitDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final data = await TeacherHabitService.getHabitDetail(widget.habitId);
      if (mounted) {
        setState(() {
          _habitData = data['data'];
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

  Future<void> _approveSubmission(int logId) async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _verifyingLogId = logId;
    });

    try {
      final result = await TeacherHabitService.approveSubmission(logId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Submission berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadHabitDetail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyetujui: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verifyingLogId = null;
        });
      }
    }
  }

  Future<void> _rejectSubmission(int logId) async {
    if (_isVerifying) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tolak Submission'),
        content: Text(
          'Apakah Anda yakin ingin menolak submission ini? Siswa dapat mengirim ulang bukti.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isVerifying = true;
      _verifyingLogId = logId;
    });

    try {
      final result = await TeacherHabitService.rejectSubmission(logId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Submission berhasil ditolak'),
          backgroundColor: Colors.orange,
        ),
      );

      await _loadHabitDetail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menolak: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verifyingLogId = null;
        });
      }
    }
  }

  void _showProofImage(String proofUrl, String studentName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bukti Habit - $studentName',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: proofUrl.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            proofUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Bukti tidak tersedia'),
                        ],
                      ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerificationDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verifikasi Bukti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Siswa: ${student['student_name']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Progress: ${student['completed_logs']}/${student['total_logs']} selesai',
            ),
            Text('Completion Rate: ${student['completion_rate']}%'),
            SizedBox(height: 16),
            if (student['can_validate_today'])
              ElevatedButton.icon(
                icon: Icon(Icons.visibility),
                label: Text('Lihat Bukti'),
                onPressed: () {
                  Navigator.pop(context);
                  _showProofImage(
                    _getStudentProofUrl(student),
                    student['student_name'],
                  );
                },
              )
            else
              Text(
                'Tidak ada submission hari ini',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          if (student['can_validate_today']) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _rejectSubmission(student['today_log_id']);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Tolak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _approveSubmission(student['today_log_id']);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Setujui'),
            ),
          ],
        ],
      ),
    );
  }

  String _getStudentProofUrl(Map<String, dynamic> student) {
    // Cari bukti dari recent submissions atau data lainnya
    final recentSubmissions = _habitData?['recent_submissions'] ?? [];
    for (var submission in recentSubmissions) {
      if (submission['student_name'] == student['student_name'] &&
          submission['proof_url'] != null) {
        return submission['proof_url'];
      }
    }
    return '';
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
        actions: [
          if (_habitData != null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadHabitDetail,
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
          : _habitData == null
          ? Center(child: Text('Data tidak ditemukan'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final habit = _habitData!['habit'];
    final statistics = _habitData!['statistics'];
    final studentProgress = _habitData!['student_progress'];
    final recentSubmissions = _habitData!['recent_submissions'];
    final kelasInfo = _habitData!['kelas_info'];

    // Filter students yang butuh validasi hari ini
    final waitingValidation = studentProgress
        .where((student) => student['can_validate_today'] == true)
        .toList();
    final otherStudents = studentProgress
        .where((student) => student['can_validate_today'] != true)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadHabitDetail,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Habit Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('🔄', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit['title'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    habit['period'] == 'daily'
                                        ? 'Harian'
                                        : 'Mingguan',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  habit['category'] ?? '',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    habit['description'] ?? '',
                    style: TextStyle(color: Color(0xFF4B5563), fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  // Habit Details
                  _buildDetailItem('Dibuat oleh', habit['created_by']),
                  if (habit['assigned_by'] != null)
                    _buildDetailItem('Ditugaskan oleh', habit['assigned_by']),
                  _buildDetailItem('XP Reward', '${habit['xp_reward']} XP'),
                  _buildDetailItem(
                    'Periode',
                    habit['period'] == 'daily' ? 'Harian' : 'Mingguan',
                  ),
                  _buildDetailItem(
                    'Tipe',
                    habit['is_assigned'] ? 'Ditugaskan' : 'Mandiri',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Statistics Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik Kelas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCircle(
                        '${statistics['participation_rate']}%',
                        'Partisipasi',
                        Color(0xFF3B82F6),
                      ),
                      _buildStatCircle(
                        '${statistics['completion_rate']}%',
                        'Penyelesaian',
                        Color(0xFF10B981),
                      ),
                      _buildStatCircle(
                        '${statistics['today_submissions']}',
                        'Hari Ini',
                        Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat(
                        'Total Siswa',
                        '${statistics['total_students']}',
                      ),
                      _buildMiniStat(
                        'Menunggu Validasi',
                        '${statistics['today_submissions']}',
                        isHighlighted: statistics['today_submissions'] > 0,
                      ),
                      _buildMiniStat(
                        'Selesai',
                        '${statistics['completed_count']}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Waiting Validation Section
          if (waitingValidation.isNotEmpty) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.warning_amber,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Menunggu Validasi Hari Ini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${waitingValidation.length} siswa',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...waitingValidation
                        .map<Widget>(
                          (student) => _buildStudentProgressItem(student, true),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],

          // Other Students Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Semua Siswa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${studentProgress.length} siswa',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (otherStudents.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Tidak ada siswa lain',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  else
                    ...otherStudents
                        .map<Widget>(
                          (student) =>
                              _buildStudentProgressItem(student, false),
                        )
                        .toList(),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Recent Submissions Section
          if (recentSubmissions.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submission Terbaru (7 Hari)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 12),
                    ...recentSubmissions
                        .map<Widget>(
                          (submission) =>
                              _buildRecentSubmissionItem(submission),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(value, style: TextStyle(color: Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _buildStatCircle(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildMiniStat(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isHighlighted ? Colors.orange : Color(0xFF111827),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildStudentProgressItem(
    Map<String, dynamic> student,
    bool isWaitingValidation,
  ) {
    final isVerifyingThis =
        _isVerifying && _verifyingLogId == student['today_log_id'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWaitingValidation
              ? Colors.orange.withOpacity(0.3)
              : Color(0xFFF3F4F6),
          width: isWaitingValidation ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3F4F6),
            ),
            child: Icon(Icons.person, color: Color(0xFF6B7280)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['student_name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${student['completed_logs']}/${student['total_logs']} selesai',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: student['completion_rate'] / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  student['latest_status_text'] ?? '',
                  style: TextStyle(
                    color: _getStatusColor(student['latest_status']),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isWaitingValidation)
            isVerifyingThis
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ElevatedButton.icon(
                    icon: Icon(Icons.verified, size: 16),
                    label: Text('Verifikasi'),
                    onPressed: () => _showVerificationDialog(student),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(
                  student['latest_status'],
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                student['latest_status_text'] ?? '',
                style: TextStyle(
                  color: _getStatusColor(student['latest_status']),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSubmissionItem(Map<String, dynamic> submission) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE5E7EB),
            ),
            child: Icon(Icons.person, size: 18, color: Color(0xFF6B7280)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission['student_name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  submission['date'] ?? '',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
                if (submission['note'] != null) ...[
                  SizedBox(height: 4),
                  Text(
                    submission['note'] ?? '',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (submission['proof_url'] != null)
            IconButton(
              icon: Icon(Icons.visibility, size: 18),
              onPressed: () => _showProofImage(
                submission['proof_url'],
                submission['student_name'],
              ),
              tooltip: 'Lihat Bukti',
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Color(0xFFF59E0B); // Orange for waiting validation
      case 'completed':
        return Color(0xFF10B981); // Green for completed
      case 'joined':
      default:
        return Color(0xFF6B7280); // Gray for joined
    }
  }
}
