import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/teacher/challenge_service.dart';

class TeacherChallengeDetailScreen extends StatefulWidget {
  final UserModel user;
  final int challengeId;

  const TeacherChallengeDetailScreen({
    Key? key,
    required this.user,
    required this.challengeId,
  }) : super(key: key);

  @override
  _TeacherChallengeDetailScreenState createState() => _TeacherChallengeDetailScreenState();
}

class _TeacherChallengeDetailScreenState extends State<TeacherChallengeDetailScreen> {
  Map<String, dynamic>? _challengeData;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isVerifying = false;
  int? _verifyingParticipantId;

  @override
  void initState() {
    super.initState();
    _loadChallengeDetail();
  }

  Future<void> _loadChallengeDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final data = await TeacherChallengeService.getChallengeDetail(widget.challengeId);
      if (mounted) {
        setState(() {
          _challengeData = data['data'];
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

  Future<void> _approveSubmission(int participantId) async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _verifyingParticipantId = participantId;
    });

    try {
      final result = await TeacherChallengeService.approveSubmission(participantId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Submission berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh data setelah approve
      await _loadChallengeDetail();
      
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
          _verifyingParticipantId = null;
        });
      }
    }
  }

  Future<void> _rejectSubmission(int participantId) async {
    if (_isVerifying) return;

    // Tampilkan dialog konfirmasi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tolak Submission'),
        content: Text('Apakah Anda yakin ingin menolak submission ini? Member dapat mengirim ulang bukti.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isVerifying = true;
      _verifyingParticipantId = participantId;
    });

    try {
      final result = await TeacherChallengeService.rejectSubmission(participantId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Submission berhasil ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Refresh data setelah reject
      await _loadChallengeDetail();
      
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
          _verifyingParticipantId = null;
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
                    'Bukti Challenge - $studentName',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 48),
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
                          Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
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

  void _showVerificationDialog(Map<String, dynamic> participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verifikasi Bukti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Member: ${participant['student_name']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Status: ${participant['status_text']}'),
            if (participant['submitted_at'] != null) ...[
              SizedBox(height: 4),
              Text('Dikirim: ${participant['submitted_at']}'),
            ],
            SizedBox(height: 16),
            if (participant['proof_url'] != null)
              ElevatedButton.icon(
                icon: Icon(Icons.visibility),
                label: Text('Lihat Bukti'),
                onPressed: () {
                  Navigator.pop(context);
                  _showProofImage(participant['proof_url'], participant['student_name']);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectSubmission(participant['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Tolak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveSubmission(participant['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Setujui'),
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
          'Detail Challenge',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        actions: [
          if (_challengeData != null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadChallengeDetail,
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
                        'Gagal memuat detail challenge',
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
                        onPressed: _loadChallengeDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _challengeData == null
                  ? Center(child: Text('Data tidak ditemukan'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final challenge = _challengeData!['challenge'];
    final statistics = _challengeData!['statistics'];
    final participants = _challengeData!['participants'];
    final kelasInfo = _challengeData!['kelas_info'];

    // Filter participants yang butuh validasi
    final waitingValidation = participants.where((p) => p['can_validate'] == true).toList();
    final otherParticipants = participants.where((p) => p['can_validate'] != true).toList();

    return RefreshIndicator(
      onRefresh: _loadChallengeDetail,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Challenge Info Card
          Card(
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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('🏆', style: TextStyle(fontSize: 24)),
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
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
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
                  SizedBox(height: 16),
                  Text(
                    challenge['description'] ?? '',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Challenge Details
                  _buildDetailItem('Dibuat oleh', challenge['created_by']),
                  _buildDetailItem('XP Reward', '${challenge['xp_reward']} XP'),
                  _buildDetailItem('Periode', '${challenge['start_date']} - ${challenge['end_date']}'),
                  _buildDetailItem('Sisa Waktu', '${challenge['days_remaining']} hari'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Statistics Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik Divisi',
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
                      _buildStatCircle('${statistics['participation_rate']}%', 'Partisipasi', Color(0xFF3B82F6)),
                      _buildStatCircle('${statistics['completion_rate']}%', 'Penyelesaian', Color(0xFF10B981)),
                      _buildStatCircle('${statistics['participants_count']}', 'Peserta', Color(0xFFF59E0B)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Total Member', '${statistics['total_students']}'),
                      _buildMiniStat('Menunggu Validasi', '${statistics['submitted_count']}', isHighlighted: statistics['submitted_count'] > 0),
                      _buildMiniStat('Selesai', '${statistics['completed_count']}'),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          child: Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Menunggu Validasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${waitingValidation.length} member',
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
                    ...waitingValidation.map<Widget>((participant) => _buildParticipantItem(participant, true)).toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],

          // Other Participants Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Semua Peserta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${participants.length} member',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (otherParticipants.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Tidak ada peserta lain',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  else
                    ...otherParticipants.map<Widget>((participant) => _buildParticipantItem(participant, false)).toList(),
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
          Text(
            value,
            style: TextStyle(
              color: Color(0xFF111827),
            ),
          ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, {bool isHighlighted = false}) {
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantItem(Map<String, dynamic> participant, bool isWaitingValidation) {
    final isVerifyingThis = _isVerifying && _verifyingParticipantId == participant['id'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWaitingValidation ? Colors.orange.withOpacity(0.3) : Color(0xFFF3F4F6),
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
                  participant['student_name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  participant['status_text'] ?? '',
                  style: TextStyle(
                    color: _getStatusColor(participant['status']),
                    fontSize: 12,
                  ),
                ),
                if (participant['submitted_at'] != null && isWaitingValidation) ...[
                  SizedBox(height: 2),
                  Text(
                    'Dikirim: ${participant['submitted_at']}',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                    ),
                  ),
                ],
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
                : Row(
                    children: [
                      if (participant['proof_url'] != null)
                        IconButton(
                          icon: Icon(Icons.visibility, size: 20),
                          onPressed: () => _showProofImage(participant['proof_url'], participant['student_name']),
                          tooltip: 'Lihat Bukti',
                        ),
                      SizedBox(width: 4),
                      ElevatedButton.icon(
                        icon: Icon(Icons.verified, size: 16),
                        label: Text('Verifikasi'),
                        onPressed: () => _showVerificationDialog(participant),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(participant['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                participant['status_text'] ?? '',
                style: TextStyle(
                  color: _getStatusColor(participant['status']),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
