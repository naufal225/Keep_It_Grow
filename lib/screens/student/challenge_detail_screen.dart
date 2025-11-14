import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep_it_grow/core/utils/date_helper.dart';
import 'package:keep_it_grow/screens/student/create_challenge_screen.dart';
import '../../models/user_model.dart';
import '../../services/challenges_service.dart';
import 'package:intl/intl.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final UserModel user;
  final int challengeId;

  const ChallengeDetailScreen({
    Key? key,
    required this.user,
    required this.challengeId,
  }) : super(key: key);

  @override
  _ChallengeDetailScreenState createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  Map<String, dynamic>? _challenge;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadChallengeDetail();
  }

  Future<void> _loadChallengeDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await ChallengesService.getChallengeDetail(
        widget.challengeId,
      );
      setState(() {
        _challenge = data['data'];
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

  Future<void> _joinChallenge() async {
    try {
      await ChallengesService.joinChallenge(widget.challengeId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil bergabung dengan challenge!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadChallengeDetail(); // Reload data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal bergabung: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      try {
        await ChallengesService.submitProof(widget.challengeId, image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bukti berhasil dikirim, menunggu verifikasi!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadChallengeDetail(); // Reload data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim bukti: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildActionButton() {
    final participation = _challenge?['user_participation'];
    final userStatus = (participation is Map && participation['status'] != null)
        ? participation['status'].toString().toLowerCase()
        : 'not_joined';

    final isOwner = _challenge?['is_owner'] == true;
    final type = _challenge?['type']?.toString().toLowerCase();

    print('Debug Action Button:');
    print('- userStatus: $userStatus');
    print('- isOwner: $isOwner');
    print('- type: $type');
    print('- participation: $participation');
    print(_challenge);

    // Jika owner dan challenge self, tampilkan BOTH: edit/hapus DAN tombol selesaikan
    if (isOwner == true &&
        type == 'self' &&
        userStatus != 'completed' &&
        userStatus != 'submitted') {
      return Column(
        children: [
          // Tombol Edit & Hapus
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateChallengeScreen(
                          user: widget.user,
                          challenge: _challenge,
                        ),
                      ),
                    ).then((refresh) {
                      if (refresh == true) _loadChallengeDetail();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'EDIT CHALLENGE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _deleteChallenge,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('HAPUS'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Tombol Selesaikan berdasarkan status
          _buildCompletionButton(userStatus),
        ],
      );
    }

    // Untuk participant biasa (bukan owner)
    return _buildCompletionButton(userStatus);
  }

  Widget _buildCompletionButton(String userStatus) {
    switch (userStatus) {
      case 'not_joined':
        return ElevatedButton(
          onPressed: _joinChallenge,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF10B981),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'KERJAKAN CHALLENGE',
            style: TextStyle(color: Colors.white),
          ),
        );

      case 'joined':
        return ElevatedButton(
          onPressed: _submitProof,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3B82F6),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'SELESAIKAN & UPLOAD BUKTI',
            style: TextStyle(color: Colors.white),
          ),
        );

      case 'submitted':
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

      case 'completed':
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
                  'Challenge telah diselesaikan!',
                  style: TextStyle(
                    color: Color(0xFF065F46),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return ElevatedButton(
          onPressed: _joinChallenge,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6B7280),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text('JOIN CHALLENGE', style: TextStyle(color: Colors.white)),
        );
    }
  }

  Future<void> _deleteChallenge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Challenge'),
        content: Text('Apakah Anda yakin ingin menghapus challenge ini?'),
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
        await ChallengesService.deleteChallenge(widget.challengeId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus challenge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          : _challenge == null
          ? Center(child: Text('Data challenge tidak ditemukan'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 40,
                          color: Color(0xFF3B82F6),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _challenge!['title'] ?? 'Challenge',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _challenge!['category'] ?? 'General',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_challenge!['xp_reward']} XP',
                            style: TextStyle(
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Description
                  Text(
                    'Deskripsi Challenge',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _challenge!['description'] ?? '',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Info
                  Text(
                    'Informasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoItem(
                          'Mulai',
                          DateHelper.formatDate(_challenge!['start_date']),
                        ),
                        _buildInfoItem(
                          'Selesai',
                          DateHelper.formatDate(_challenge!['end_date']),
                        ),

                        _buildInfoItem(
                          'Peserta',
                          '${_challenge!['total_participants']} orang',
                        ),
                        _buildInfoItem(
                          'Tipe',
                          _challenge!['type'] == 'self'
                              ? 'Challenge Self'
                              : 'Challenge Terassign',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Status Participation
                  if (_challenge!['user_participation'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Partisipasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildStatusItem(
                                'Status',
                                _challenge!['user_participation']['status'],
                              ),
                              if (_challenge!['user_participation']['submitted_at'] !=
                                  null)
                                _buildStatusItem(
                                  'Dikirim pada',
                                 DateHelper.formatDate( _challenge!['user_participation']['submitted_at']),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),

                  // Action Button
                  _buildActionButton(),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    Color statusColor = Color(0xFF6B7280);

    if (value == 'joined') statusColor = Color(0xFF3B82F6);
    if (value == 'submitted') statusColor = Color(0xFFF59E0B);
    if (value == 'completed') statusColor = Color(0xFF10B981);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
