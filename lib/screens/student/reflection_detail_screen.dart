import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/user_model.dart';
import 'package:keep_it_grow/services/reflection_service.dart';
import 'package:keep_it_grow/screens/student/create_reflection_screen.dart';
import 'package:intl/intl.dart';

class ReflectionDetailScreen extends StatefulWidget {
  final UserModel user;
  final int reflectionId;

  const ReflectionDetailScreen({
    Key? key,
    required this.user,
    required this.reflectionId,
  }) : super(key: key);

  @override
  _ReflectionDetailScreenState createState() => _ReflectionDetailScreenState();
}

class _ReflectionDetailScreenState extends State<ReflectionDetailScreen> {
  Map<String, dynamic>? _reflection;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadReflectionDetail();
  }

  Future<void> _loadReflectionDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await ReflectionService.getReflections();
      final reflections = data['data'] ?? [];
      final reflection = reflections.firstWhere(
        (ref) => ref['id'] == widget.reflectionId,
        orElse: () => null,
      );

      if (reflection != null) {
        setState(() {
          _reflection = reflection;
        });
      } else {
        setState(() {
          _errorMessage = 'Refleksi tidak ditemukan';
        });
      }
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

  Future<void> _deleteReflection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Refleksi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus refleksi ini? Tindakan ini tidak dapat dibatalkan.',
        ),
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
        await ReflectionService.deleteReflection(widget.reflectionId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refleksi berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus refleksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHeaderCard() {
    final mood = _reflection!['mood'] ?? 'neutral';
    final content = _reflection!['body'] ?? '';
    final date = _reflection!['date'] ?? '';
    final moodColor = _getMoodColor(mood);
    final moodIcon = _getMoodIcon(mood);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood and Date Row
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: moodColor, width: 2),
                ),
                child: Center(
                  child: Icon(moodIcon, color: moodColor, size: 30),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMoodText(mood),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'EEEE, dd MMMM yyyy',
                      ).format(DateTime.parse(date)),
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Content - Note Style
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E7EB), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Catatan Refleksi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodInsights() {
    final mood = _reflection!['mood'] ?? 'neutral';
    final moodColor = _getMoodColor(mood);

    String getMoodInsight(String mood) {
      switch (mood) {
        case 'happy':
          return 'Hari yang menyenangkan! Terus pertahankan energi positifmu.';
        case 'sad':
          return 'Setiap perasaan memiliki waktunya. Izinkan dirimu untuk merasakan dan belajar dari pengalaman ini.';
        case 'angry':
          return 'Marah adalah emosi yang wajar. Coba cari akar perasaanmu dan ekspresikan dengan sehat.';
        case 'tired':
          return 'Tubuh dan pikiranmu butuh istirahat. Luangkan waktu untuk self-care.';
        default: // neutral
          return 'Hari yang tenang. Perhatikan momen-momen kecil yang membuatmu bersyukur.';
      }
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: moodColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: moodColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: moodColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Insight & Saran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: moodColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: moodColor.withOpacity(0.2), width: 1),
            ),
            child: Text(
              getMoodInsight(mood),
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
                height: 1.5,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionDetails() {
    final date = _reflection!['date'] ?? '';
    final createdAt = _reflection!['created_at'] ?? '';
    final updatedAt = _reflection!['updated_at'] ?? '';

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
            'Detail Refleksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            'Tanggal Refleksi',
            DateFormat('dd MMMM yyyy').format(DateTime.parse(date)),
            Icons.calendar_today,
          ),
          _buildDetailRow(
            'Dibuat pada',
            DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(createdAt)),
            Icons.create,
          ),
          if (updatedAt != createdAt)
            _buildDetailRow(
              'Diupdate pada',
              DateFormat(
                'dd MMM yyyy • HH:mm',
              ).format(DateTime.parse(updatedAt)),
              Icons.update,
            ),
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
    return Column(
      children: [
        // Edit Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateReflectionScreen(
                    user: widget.user,
                    reflection: _reflection,
                  ),
                ),
              ).then((refresh) {
                if (refresh == true) {
                  _loadReflectionDetail();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Edit Refleksi'),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),

        // Delete Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFEF4444)),
          ),
          child: OutlinedButton(
            onPressed: _deleteReflection,
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFFEF4444),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, size: 18),
                SizedBox(width: 8),
                Text('Hapus Refleksi'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      case 'tired':
        return Icons.sentiment_dissatisfied;
      default: // neutral
        return Icons.sentiment_neutral;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
        return Color(0xFF10B981);
      case 'sad':
        return Color(0xFF3B82F6);
      case 'angry':
        return Color(0xFFEF4444);
      case 'tired':
        return Color(0xFF8B5CF6);
      default: // neutral
        return Color(0xFFF59E0B);
    }
  }

  String _getMoodText(String mood) {
    switch (mood) {
      case 'happy':
        return 'Senang';
      case 'sad':
        return 'Sedih';
      case 'angry':
        return 'Marah';
      case 'tired':
        return 'Lelah';
      default: // neutral
        return 'Biasa Saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Detail Refleksi',
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
                    'Gagal memuat detail refleksi',
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
                    onPressed: _loadReflectionDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _reflection == null
          ? Center(child: Text('Data refleksi tidak ditemukan'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  SizedBox(height: 20),
                  _buildMoodInsights(),
                  SizedBox(height: 20),
                  _buildReflectionDetails(),
                  SizedBox(height: 20),
                  _buildActionButtons(),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
