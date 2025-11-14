import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/parent_support_model.dart'; // IMPORT MODEL
import 'package:keep_it_grow/services/parent/support_service.dart';
import 'package:keep_it_grow/core/utils/avatar_helper.dart';

class SupportHistoryScreen extends StatefulWidget {
  const SupportHistoryScreen({Key? key}) : super(key: key);

  @override
  _SupportHistoryScreenState createState() => _SupportHistoryScreenState();
}

class _SupportHistoryScreenState extends State<SupportHistoryScreen> {
  SupportHistory? _supportHistory;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSupportHistory();
  }

  Future<void> _loadSupportHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ParentSupportService.getSupportHistory();
      if (result['success'] == true) {
        setState(() {
          _supportHistory = SupportHistory.fromJson(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat riwayat dukungan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  String _getAvatarUrl(String? avatarPath) {
    return AvatarHelper.getAvatarUrl(avatarPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Riwayat Dukungan'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSupportHistory,
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_supportHistory == null || _supportHistory!.supports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat dukungan',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 8),
            Text(
              'Kirim pesan dukungan pertama Anda kepada anak',
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
            SizedBox(height: 24),
            
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSupportHistory,
      child: Column(
        children: [
          // Header Stats
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Dikirim',
                  '${_supportHistory!.totalSent}',
                  Icons.send,
                  Color(0xFF3B82F6),
                ),
                _buildStatItem(
                  'Belum Dibaca',
                  '${_supportHistory!.totalUnreadByStudents}',
                  Icons.mark_email_unread,
                  Color(0xFFEC4899),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          // List Support
          Expanded(
            child: ListView.builder(
              itemCount: _supportHistory!.supports.length,
              itemBuilder: (context, index) {
                final support = _supportHistory!.supports[index];
                return _buildSupportItem(support);
              },
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
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportItem(ParentSupport support) {
    final avatarUrl = _getAvatarUrl(support.studentAvatar);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan info siswa dan status
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3F4F6),
                  ),
                  child: avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            avatarUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 20,
                                color: Color(0xFF6B7280),
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        support.studentName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        support.sentAt,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: support.isRead
                        ? Color(0xFF10B981).withOpacity(0.1)
                        : Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    support.isRead ? 'Dibaca' : 'Belum Dibaca',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: support.isRead ? Color(0xFF10B981) : Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Pesan
            Text(
              support.message,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
            SizedBox(height: 8),
            // Info baca
            if (support.isRead && support.readAt != null)
              Text(
                'Dibaca pada: ${support.readAt}',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}