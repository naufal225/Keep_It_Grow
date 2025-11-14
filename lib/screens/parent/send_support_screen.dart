import 'package:flutter/material.dart';
import 'package:keep_it_grow/services/parent/support_service.dart';

class SendSupportScreen extends StatefulWidget {
  final int studentId;
  final String studentName;
  final String studentClass;

  const SendSupportScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
    required this.studentClass,
  }) : super(key: key);

  @override
  _SendSupportScreenState createState() => _SendSupportScreenState();
}

class _SendSupportScreenState extends State<SendSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendSupport() async {
    if (_messageController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Pesan dukungan harus diisi';
      });
      return;
    }

    if (_messageController.text.length < 5) {
      setState(() {
        _errorMessage = 'Pesan dukungan minimal 5 karakter';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ParentSupportService.sendSupport(
        studentId: widget.studentId,
        message: _messageController.text,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Pesan dukungan berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke screen sebelumnya
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal mengirim pesan dukungan';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Kirim Dukungan'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Anak
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.child_care, size: 24, color: Color(0xFFEC4899)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            widget.studentClass,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Form Pesan
            Text(
              'Pesan Dukungan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _messageController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan dukungan untuk anak Anda...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_messageController.text.length}/500 karakter',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        if (_messageController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _messageController.clear();
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                            tooltip: 'Hapus pesan',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),

            // Button Kirim
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendSupport,
                icon: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.send, size: 20),
                label: Text(_isLoading ? 'Mengirim...' : 'Kirim Dukungan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEC4899),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Tips
            SizedBox(height: 24),
            Card(
              elevation: 1,
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
                        Icon(Icons.lightbulb, size: 20, color: Color(0xFFF59E0B)),
                        SizedBox(width: 8),
                        Text(
                          'Tips Pesan Dukungan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Berikan pujian untuk pencapaian mereka\n• Semangati untuk terus belajar\n• Beri motivasi untuk menghadapi tantangan\n• Ekspresikan kebanggaan Anda',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}