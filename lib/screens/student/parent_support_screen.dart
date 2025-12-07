import 'package:flutter/material.dart';
import '../../services/student/parent_support_service.dart';
import 'package:keep_it_grow/models/student_parent_support_models.dart';
import 'parent_support_detail_screen.dart';

class StudentParentSupportScreen extends StatefulWidget {
  const StudentParentSupportScreen({Key? key}) : super(key: key);

  @override
  _StudentParentSupportScreenState createState() => _StudentParentSupportScreenState();
}

class _StudentParentSupportScreenState extends State<StudentParentSupportScreen> {
  late Future<StudentParentSupportResponse> _parentSupportsFuture;
  final ParentSupportService _parentSupportService = ParentSupportService();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadParentSupports();
  }

  Future<void> _loadParentSupports() async {
    setState(() {
      _parentSupportsFuture = _parentSupportService.getParentSupports();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadParentSupports();
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _markAllAsRead() async {
    try {
      await _parentSupportService.markAllAsRead();
      _loadParentSupports(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua pesan ditandai sebagai sudah dibaca'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menandai pesan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToDetail(StudentParentSupport support) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentSupportDetailScreen(
          parentSupport: support,
          onMarkAsRead: () => _markSupportAsRead(support.id),
        ),
      ),
    );
  }

  Future<void> _markSupportAsRead(int supportId) async {
    try {
      await _parentSupportService.markAsRead(supportId);
      _loadParentSupports(); // Refresh data
    } catch (e) {
      print('Gagal menandai pesan sebagai dibaca: $e');
    }
  }

  Widget _buildSupportCard(StudentParentSupport support) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: support.isRead ? Colors.white : Color(0xFFEFF6FF),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF3F4F6),
          ),
          child: support.parentAvatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    support.parentAvatarUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, color: Color(0xFF6B7280));
                    },
                  ),
                )
              : Icon(Icons.person, color: Color(0xFF6B7280)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              support.parentName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 2),
            Text(
              '@${support.parentUsername}',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              support.message.length > 100
                  ? '${support.message.substring(0, 100)}...'
                  : support.message,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Color(0xFF9CA3AF)),
                SizedBox(width: 4),
                Text(
                  support.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Spacer(),
                if (!support.isRead)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Baru',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          support.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
          color: support.isRead ? Color(0xFF10B981) : Color(0xFFF59E0B),
        ),
        onTap: () => _navigateToDetail(support),
      ),
    );
  }

  Widget _buildHeader(int unreadCount, int totalCount) {
    return Container(
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
          Icon(Icons.family_restroom, color: Color(0xFF3B82F6)),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dukungan Family',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                '$unreadCount belum dibaca • Total $totalCount pesan',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Spacer(),
          if (unreadCount > 0)
            IconButton(
              icon: Icon(Icons.mark_email_read),
              onPressed: _markAllAsRead,
              tooltip: 'Tandai Semua Sudah Dibaca',
              color: Color(0xFF3B82F6),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Memuat pesan dukungan...',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            SizedBox(height: 16),
            Text(
              'Gagal Memuat Pesan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadParentSupports,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 80, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            'Belum Ada Pesan Dukungan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Family Anda akan mengirimkan pesan\nmotivasi dan dukungan di sini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
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
        title: Text('Dukungan Family'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        actions: [
          if (_isRefreshing)
            Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: FutureBuilder<StudentParentSupportResponse>(
        future: _parentSupportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            
            if (data.parentSupports.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildHeader(data.unreadCount, data.totalCount),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      itemCount: data.parentSupports.length,
                      itemBuilder: (context, index) {
                        return _buildSupportCard(data.parentSupports[index]);
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }
}
