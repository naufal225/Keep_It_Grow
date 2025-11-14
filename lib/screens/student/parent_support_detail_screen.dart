import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/student_parent_support_models.dart';

class ParentSupportDetailScreen extends StatefulWidget {
  final StudentParentSupport parentSupport;
  final VoidCallback? onMarkAsRead;

  const ParentSupportDetailScreen({
    Key? key,
    required this.parentSupport,
    this.onMarkAsRead,
  }) : super(key: key);

  @override
  _ParentSupportDetailScreenState createState() => _ParentSupportDetailScreenState();
}

class _ParentSupportDetailScreenState extends State<ParentSupportDetailScreen> {
  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    _isRead = widget.parentSupport.isRead;
    
    // Auto mark as read jika belum dibaca
    if (!_isRead && widget.onMarkAsRead != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMarkAsRead!();
        setState(() {
          _isRead = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final support = widget.parentSupport;

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Pesan Dukungan'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header dengan info orang tua
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3F4F6),
                  ),
                  child: support.parentAvatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            support.parentAvatarUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, size: 30, color: Color(0xFF6B7280));
                            },
                          ),
                        )
                      : Icon(Icons.person, size: 30, color: Color(0xFF6B7280)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        support.parentName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '@${support.parentUsername}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        support.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isRead 
                        ? Color(0xFF10B981).withOpacity(0.1)
                        : Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                        size: 14,
                        color: _isRead ? Color(0xFF10B981) : Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 4),
                      Text(
                        _isRead ? 'Dibaca' : 'Belum Dibaca',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isRead ? Color(0xFF10B981) : Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1),
          
          // Konten pesan
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon motivasi
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 40,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Judul
                    Center(
                      child: Text(
                        'Pesan Dukungan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Tanggal lengkap
                    Center(
                      child: Text(
                        'Dikirim pada: ${support.createdAt}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Pesan
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        support.message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF374151),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Info status baca
                    if (_isRead && support.readAt != null)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFD1FAE5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 20, color: Color(0xFF10B981)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pesan ini telah dibaca pada: ${support.readAt}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    SizedBox(height: 20),
                    
                    // Tombol aksi
                    if (!_isRead)
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.onMarkAsRead != null) {
                              widget.onMarkAsRead!();
                              setState(() {
                                _isRead = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pesan ditandai sebagai sudah dibaca'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.mark_email_read),
                          label: Text('Tandai Sudah Dibaca'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}