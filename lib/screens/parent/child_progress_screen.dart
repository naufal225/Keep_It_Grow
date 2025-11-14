import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/child_progress_model.dart';
import 'package:keep_it_grow/services/parent/child_progress_service.dart';
import 'package:keep_it_grow/core/utils/avatar_helper.dart';
import 'package:keep_it_grow/screens/parent/send_support_screen.dart'; // Import baru
import 'package:keep_it_grow/screens/parent/support_history_screen.dart'; // Import baru

class ChildProgressScreen extends StatefulWidget {
  final int initialChildId;

  const ChildProgressScreen({Key? key, required this.initialChildId})
    : super(key: key);

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  List<ChildBasicInfo> _children = [];
  ChildProgress? _currentChildProgress;
  int _selectedChildIndex = 0;
  bool _isLoading = true;
  bool _isLoadingProgress = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // Load data semua anak dulu
      final childrenData = await ChildProgressService.getAllChildrenProgress();
      if (childrenData['success'] == true) {
        final childrenList = (childrenData['data']['children'] as List)
            .map((child) => ChildBasicInfo.fromJson(child))
            .toList();

        setState(() {
          _children = childrenList;
        });

        // Cari index anak yang dipilih
        final initialIndex = _children.indexWhere(
          (child) => child.id == widget.initialChildId,
        );
        final targetIndex = initialIndex != -1
            ? initialIndex
            : (_children.isNotEmpty ? 0 : -1);

        if (targetIndex != -1) {
          setState(() {
            _selectedChildIndex = targetIndex;
          });
          // Load progress anak yang dipilih
          await _loadChildProgress(_children[targetIndex].id);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Tidak ada data anak';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = childrenData['message'] ?? 'Gagal memuat data anak';
        });
      }
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  Future<void> _loadChildProgress(int childId) async {
    if (mounted) {
      setState(() {
        _isLoadingProgress = true;
        _errorMessage = '';
      });
    }

    try {
      final progressData = await ChildProgressService.getChildProgress(childId);
      if (progressData['success'] == true) {
        if (mounted) {
          setState(() {
            _currentChildProgress = ChildProgress.fromJson(
              progressData['data'],
            );
            _isLoading = false;
            _isLoadingProgress = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingProgress = false;
            _errorMessage =
                progressData['message'] ?? 'Gagal memuat progress anak';
          });
        }
      }
    } catch (e) {
      print('Error loading child progress: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingProgress = false;
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        });
      }
    }
  }

  void _onChildSelected(int index) {
    if (index != _selectedChildIndex && index < _children.length) {
      setState(() {
        _selectedChildIndex = index;
      });
      _loadChildProgress(_children[index].id);
    }
  }

  // Helper untuk mendapatkan avatar URL yang benar
  String _getAvatarUrl(String? avatarPath) {
    return AvatarHelper.getAvatarUrl(avatarPath);
  }

  // Navigasi ke screen kirim support
  void _navigateToSendSupport() {
    final currentChild = _children[_selectedChildIndex];
    print("CURRENT CHILD: ${currentChild}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendSupportScreen(
          studentId: currentChild.id,
          studentName: currentChild.name,
          studentClass: currentChild.className,
        ),
      ),
    );
  }

  // Navigasi ke screen riwayat support
  void _navigateToSupportHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SupportHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Progress Anak'),
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
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_currentChildProgress == null || _children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 16),
            Text(
              'Tidak ada data anak',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async =>
              _loadChildProgress(_children[_selectedChildIndex].id),
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              if (_children.length > 1) _buildSegmentedControl(),
              SizedBox(height: 16),
              _buildHeaderSection(),
              SizedBox(height: 24),
              _buildProgressBarSection(),
              SizedBox(height: 24),
              _buildActivityChartSection(),
              SizedBox(height: 24),
              _buildSummarySection(),
              SizedBox(height: 24),
              _buildSupportButtons(), // TAMBAHKAN BUTTON SUPPORT DI SINI
              SizedBox(height: 24),
            ],
          ),
        ),
        if (_isLoadingProgress)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  // WIDGET BARU: Button Support
  Widget _buildSupportButtons() {
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
        children: [
          Text(
            'Berikan Dukungan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToSendSupport,
              icon: Icon(Icons.favorite, size: 20),
              label: Text('Kirim Pesan Dukungan'),
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
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _navigateToSupportHistory,
              icon: Icon(Icons.history, size: 20),
              label: Text('Lihat Riwayat Dukungan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF6B7280),
                side: BorderSide(color: Color(0xFFD1D5DB)),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget-widget lainnya tetap sama...
  Widget _buildSegmentedControl() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_children.length, (index) {
          final child = _children[index];
          final isSelected = index == _selectedChildIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onChildSelected(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar kecil untuk tab
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF9FAFB),
                      ),
                      child: _buildTabAvatar(child.avatarUrl),
                    ),
                    SizedBox(height: 4),
                    Text(
                      child.name.split(' ').first,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Color(0xFF3B82F6)
                            : Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabAvatar(String? avatarPath) {
    final avatarUrl = _getAvatarUrl(avatarPath);

    if (avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildTabPlaceholderAvatar();
          },
        ),
      );
    } else {
      return _buildTabPlaceholderAvatar();
    }
  }

  Widget _buildTabPlaceholderAvatar() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: Center(
        child: Icon(Icons.person, size: 12, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final child = _currentChildProgress!;
    final avatarUrl = _getAvatarUrl(child.avatarUrl);

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
      child: Row(
        children: [
          // Avatar utama
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF9FAFB),
            ),
            child: avatarUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildHeaderPlaceholderAvatar();
                      },
                    ),
                  )
                : _buildHeaderPlaceholderAvatar(),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  child.className,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
                    SizedBox(width: 4),
                    Text(
                      'Level ${child.level}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: Color(0xFF3B82F6),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${child.xp} XP',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPlaceholderAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Center(
        child: Icon(Icons.person, size: 30, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildProgressBarSection() {
    final child = _currentChildProgress!;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                'Level ${child.level}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                height: 12,
                width:
                    (MediaQuery.of(context).size.width - 72) *
                    (child.xpProgress / 100),
                decoration: BoxDecoration(
                  color: Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${child.xp} XP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                '${child.xpForNextLevel} XP untuk Level ${child.level + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${child.xpProgress}% menuju Level ${child.level + 1}',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return ClipOval(
      child: Image.network(
        'https://via.placeholder.com/60x60/cccccc/969696?text=Avatar',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Center(
              child: Icon(Icons.person, size: 30, color: Colors.grey[500]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityChartSection() {
    final weeklyActivity = _currentChildProgress!.weeklyActivity;

    // Cari nilai maksimum untuk scaling
    int maxActivity = 1;
    for (var activity in weeklyActivity) {
      if (activity.totalActivity > maxActivity) {
        maxActivity = activity.totalActivity;
      }
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas 7 Hari Terakhir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Icon(Icons.bar_chart, color: Color(0xFF6B7280)),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 180,
            child: weeklyActivity.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data aktivitas',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weeklyActivity.length,
                    itemBuilder: (context, index) {
                      final activity = weeklyActivity[index];
                      final heightFactor = maxActivity > 0
                          ? activity.totalActivity / maxActivity
                          : 0.0;

                      return Container(
                        width: 50,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 20,
                              child: Center(
                                child: Text(
                                  '${activity.totalActivity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              height: 80 * heightFactor,
                              decoration: BoxDecoration(
                                color: Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 20,
                              child: Center(
                                child: Text(
                                  activity.day,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              height: 16,
                              child: Center(
                                child: Text(
                                  activity.dayShort,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final summary = _currentChildProgress!.summary;

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
            'Ringkasan Minggu Ini',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildSummaryItem(index, summary);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(int index, WeeklySummary summary) {
    final items = [
      {
        'icon': Icons.check_circle,
        'color': Color(0xFF10B981),
        'title': 'Habit Selesai',
        'value': '${summary.habitsCompleted}/${summary.habitsExpected}',
        'subtitle': '${summary.habitsPercentage.round()}%',
      },
      {
        'icon': Icons.emoji_events,
        'color': Color(0xFFF59E0B),
        'title': 'Challenge Selesai',
        'value': '${summary.challengesCompleted}',
        'subtitle': 'Minggu ini',
      },
      {
        'icon': Icons.lightbulb,
        'color': Color(0xFF8B5CF6),
        'title': 'Refleksi Dibuat',
        'value': '${summary.reflectionsCreated}',
        'subtitle': 'Minggu ini',
      },
      {
        'icon': Icons.star,
        'color': Color(0xFFEC4899),
        'title': 'XP Diperoleh',
        'value': '${summary.totalXpEarned}',
        'subtitle': 'XP minggu ini',
      },
    ];

    final item = items[index];

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item['color'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item['icon'] as IconData,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  item['subtitle'] as String,
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
