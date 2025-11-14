import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/user_model.dart';
import 'package:keep_it_grow/services/auth_service.dart';
import 'package:keep_it_grow/services/reflection_service.dart';
import 'package:keep_it_grow/screens/student/create_reflection_screen.dart';
import 'package:keep_it_grow/screens/student/reflection_detail_screen.dart';
import 'package:intl/intl.dart';

class ReflectionScreen extends StatefulWidget {
  final UserModel user;

  const ReflectionScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ReflectionScreenState createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  List<Map<String, dynamic>> _reflections = [];

  bool _isLoading = true;
  String _errorMessage = '';
  String? _selectedMonth;
  Map<String, dynamic>? _todayReflection;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    print('🔄 Starting to load initial data...');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Cek token dulu
      final token = await AuthService.getToken();
      print('🔑 Current token: ${token != null ? "Available" : "NULL"}');

      if (token == null) {
        throw Exception('Anda belum login. Silakan login terlebih dahulu.');
      }

      // Load data secara sequential dengan error handling yang lebih baik
      await _loadReflections();
      await _loadTodayReflection();
      await _loadStats();

      print('✅ All data loaded successfully');
    } catch (e) {
      print('❌ Error in _loadInitialData: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      print('🏁 Setting isLoading to false');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReflections() async {
    try {
      final data = await ReflectionService.getReflections(
        month: _selectedMonth,
      );

      // Handle type conversion dengan benar
      final List<dynamic> rawReflections = data['data'] ?? [];
      final List<Map<String, dynamic>> convertedReflections = [];

      for (var item in rawReflections) {
        if (item is Map<String, dynamic>) {
          convertedReflections.add(item);
        } else {
          // Convert jika tipe data tidak sesuai
          convertedReflections.add(Map<String, dynamic>.from(item));
        }
      }

      setState(() {
        _reflections = convertedReflections;
        print('📝 Loaded ${_reflections.length} reflections');
      });
    } catch (e) {
      print('❌ Error loading reflections: $e');
      rethrow; // Biarkan error di-handle oleh _loadInitialData
    }
  }

  Future<void> _loadTodayReflection() async {
    try {
      final data = await ReflectionService.getTodayReflection();
      final rawReflection = data['data'];

      if (rawReflection != null) {
        // Langsung gunakan data dari API
        setState(() {
          _todayReflection = rawReflection as Map<String, dynamic>;
        });
        print('📝 Today reflection loaded: ${_todayReflection?['mood']}');
      } else {
        print('📝 No reflection found for today');
        setState(() {
          _todayReflection = null;
        });
      }
    } catch (e) {
      print('⚠️ Error loading today reflection: $e');
      setState(() {
        _todayReflection = null;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final data = await ReflectionService.getReflectionStats();
      setState(() {
        _stats = data['data'];
      });
    } catch (e) {
      print('⚠️ Error loading stats: $e');
      // Jangan rethrow, set default stats
      setState(() {
        _stats = {
          'total_reflections': 0,
          'reflections_with_body': 0,
          'current_streak': 0,
          'mood_distribution': {},
        };
      });
    }
  }

  // Future<void> _loadReflections() async {
  //   try {
  //     print('Loading reflections...');
  //     final data = await ReflectionService.getReflections(
  //       month: _selectedMonth,
  //     );
  //     print('Reflections loaded: ${data['data']?.length ?? 0} items');

  //     setState(() {
  //       _reflections = data['data'] ?? [];
  //     });
  //   } catch (e) {
  //     print('Error loading reflections: $e');
  //     // Jangan set error message di sini, biarkan _loadInitialData yang handle
  //     rethrow;
  //   }
  // }

  // Future<void> _loadTodayReflection() async {
  //   try {
  //     print('Loading today reflection...');
  //     final data = await ReflectionService.getTodayReflection();
  //     print('Today reflection: ${data['data']}');

  //     setState(() {
  //       _todayReflection = data['data'];
  //     });
  //   } catch (e) {
  //     print('Error loading today reflection: $e');
  //     // Set todayReflection ke null jika error
  //     setState(() {
  //       _todayReflection = null;
  //     });
  //   }
  // }

  // Future<void> _loadStats() async {
  //   try {
  //     print('Loading stats...');
  //     final data = await ReflectionService.getReflectionStats();
  //     print('Stats loaded: $data');

  //     setState(() {
  //       _stats = data['data'];
  //     });
  //   } catch (e) {
  //     print('Error loading stats: $e');
  //     // Set stats ke null jika error
  //     setState(() {
  //       _stats = null;
  //     });
  //   }
  // }

  Widget _buildHeader() {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Refleksi Harian",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Catat perasaan dan pembelajaranmu hari ini",
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
              border: Border.all(color: Color(0xFFF59E0B), width: 2),
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: 30,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReflectionCard() {
    if (_todayReflection == null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateReflectionScreen(user: widget.user),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadInitialData();
            }
          });
        },
        child: Container(
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
            border: Border.all(color: Color(0xFFF59E0B), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Color(0xFFF59E0B)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Belum ada refleksi hari ini",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Klik untuk menulis refleksi harianmu",
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Color(0xFF6B7280), size: 16),
            ],
          ),
        ),
      );
    }

    final reflection = _todayReflection!;
    final mood = reflection['mood'] ?? 'neutral';
    final body = reflection['body'] ?? '';
    final date = reflection['date'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReflectionDetailScreen(
              user: widget.user,
              reflectionId: reflection['id'],
            ),
          ),
        ).then((refresh) {
          if (refresh == true) {
            _loadInitialData();
          }
        });
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMoodIcon(mood),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Refleksi Hari Ini",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMoodColor(mood).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getMoodText(mood),
                    style: TextStyle(
                      color: _getMoodColor(mood),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              body.length > 100 ? '${body.substring(0, 100)}...' : body,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.5,
              ),
            ), ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalReflections = _stats?['total_reflections'] ?? 0;
    final reflectionsWithBody = _stats?['reflections_with_body'] ?? 0;
    final currentStreak = _stats?['current_streak'] ?? 0;
    final moodDistribution = _stats?['mood_distribution'] ?? {};

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
                "$totalReflections",
                "Total",
                Icons.book,
                Color(0xFF3B82F6),
              ),
              _buildStatItem(
                "$reflectionsWithBody",
                "Dengan Konten",
                Icons.article,
                Color(0xFF10B981),
              ),
              _buildStatItem(
                "$currentStreak",
                "Streak",
                Icons.local_fire_department,
                Color(0xFFEF4444),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (moodDistribution.isNotEmpty) ...[
            Text(
              "Distribusi Mood Bulan Ini",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: moodDistribution.entries.map<Widget>((entry) {
                return _buildMoodDistributionItem(entry.key, entry.value);
              }).toList(),
            ),
          ],
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

  Widget _buildMoodDistributionItem(String mood, int count) {
    return Column(
      children: [
        _buildMoodIcon(mood, size: 32),
        SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 2),
        Text(
          _getMoodText(mood),
          style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildReflectionCard(Map<String, dynamic> reflection) {
    final mood = reflection['mood'] ?? 'neutral';
    final body = reflection['body'] ?? '';
    final date = reflection['date'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: _buildMoodIcon(mood),
        title: Text(
          DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              body.length > 80 ? '${body.substring(0, 80)}...' : body,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF6B7280),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReflectionDetailScreen(
                user: widget.user,
                reflectionId: reflection['id'],
              ),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadReflections();
            }
          });
        },
      ),
    );
  }

  Widget _buildMoodIcon(String mood, {double size = 40}) {
    final color = _getMoodColor(mood);
    final icon = _getMoodIcon(mood);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }

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
        return 'Biasa';
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.psychology_outlined, size: 80, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            "Belum ada refleksi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Mulai dengan menulis refleksi harian pertamamu",
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateReflectionScreen(user: widget.user),
                ),
              ).then((refresh) {
                if (refresh == true) {
                  _loadInitialData();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Tulis Refleksi Pertama'),
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
          'Refleksi Harian',
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
                    'Gagal memuat refleksi',
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
                    onPressed: _loadInitialData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildTodayReflectionCard(),
                    SizedBox(height: 24),
                    _buildStatsCard(),
                    SizedBox(height: 24),
                    // Change the declaration at the top of your class

                    // Then in your build method, replace the problematic section with:
                    _reflections.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Riwayat Refleksi",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 16),
                              // Tampilkan daftar reflections
                              Column(
                                children: _reflections
                                    .map<Widget>(
                                      (reflection) =>
                                          _buildReflectionCard(reflection),
                                    )
                                    .toList(),
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
              builder: (context) => CreateReflectionScreen(user: widget.user),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadInitialData();
            }
          });
        },
        backgroundColor: Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
