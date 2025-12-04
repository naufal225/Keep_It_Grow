import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/child_model.dart';
import 'package:keep_it_grow/models/user_model.dart';
import 'package:keep_it_grow/screens/parent/profile_screen.dart';
import 'package:keep_it_grow/services/constants.dart';
import 'package:keep_it_grow/services/parent/parent_dashboard_service.dart';
import 'package:keep_it_grow/screens/placeholder_screen.dart';
import 'package:keep_it_grow/screens/parent/child_progress_screen.dart'; // Tambahkan import ini

class ParentDashboardScreen extends StatefulWidget {
  final UserModel user;

  const ParentDashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _initializeScreens() {
    setState(() {
      _screens = [
        _DashboardContent(
          user: widget.user,
          dashboardData: _dashboardData,
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onRefresh: _loadDashboardData,
        ),
        ParentProfileScreen(user: widget.user),
      ];
    });
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final data = await ParentDashboardService.getParentDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
        _initializeScreens();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        _initializeScreens();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_screens.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF3B82F6),
        unselectedItemColor: Color(0xFF6B7280),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic>? dashboardData;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRefresh;

  const _DashboardContent({
    Key? key,
    required this.user,
    required this.dashboardData,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  }) : super(key: key);

  void _navigateToChildProgress(BuildContext context, Child child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildProgressScreen(initialChildId: child.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: Text('Refresh')),
          ],
        ),
      );
    }

    final data = dashboardData?['data'];
    if (data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Data tidak valid'),
            SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: Text('Refresh')),
          ],
        ),
      );
    }

    final parent = data['parent'] ?? {};
    final children = data['children'] ?? [];
    final summary = data['summary'] ?? {};

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => onRefresh(),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildHeaderSection(parent),
                  SizedBox(height: 24),
                  _buildStatsSection(summary),
                  SizedBox(height: 24),
                  _buildChildrenSection(context, children),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> parent) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
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
                  "Selamat datang, Ibu/Bapak ${parent['name']?.split(' ').first ?? ''} 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Pantau perkembangan anak-anak Anda",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF3B82F6), width: 2),
                ),
                child: parent['avatar_url'] != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          parent['avatar_url'].startsWith('http')
                              ? parent['avatar_url']
                              : ServiceConstants.storageBase +
                                    parent['avatar_url'],
                        ),
                      )
                    : Icon(Icons.person, color: Color(0xFF6B7280)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Ortu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> summary) {
    final List<Map<String, dynamic>> stats = [
      // Tentukan tipe data secara eksplisit
      {
        'icon': Icons.people_alt_outlined,
        'title': 'Total Anak',
        'value': summary['total_children']?.toString() ?? '0',
        'color': 'info',
      },
      {
        'icon': Icons.star_border,
        'title': 'Total XP',
        'value': summary['total_xp']?.toString() ?? '0',
        'color': 'warning',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ringkasan Keluarga",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            fontFamily: 'Poppins',
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
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildAvatarStatCard(
              stat['icon'] as IconData, // Pastikan ini IconData
              stat['title'] as String, // Cast ke String
              stat['value'] as String, // Cast ke String
              _getColorForStat(stat['color'] as String), // Cast ke String
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvatarStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
          // Avatar-style container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Center(child: Icon(icon, size: 24, color: color)),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForStat(String color) {
    switch (color) {
      case 'warning':
        return Color(0xFFF59E0B);
      case 'info':
        return Color(0xFF3B82F6);
      case 'success':
        return Color(0xFF10B981);
      default:
        return Color(0xFF6B7280);
    }
  }

  Widget _buildChildrenSection(BuildContext context, List<dynamic> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Anak Saya",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 16),
        children.isEmpty
            ? _buildEmptyState('Belum ada anak terdaftar', Icons.child_care)
            : Column(
                children: children.map<Widget>((childData) {
                  final child = Child.fromJson(childData);
                  return _buildChildCard(context, child);
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildChildCard(BuildContext context, Child child) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _navigateToChildProgress(context, child);
        },
        borderRadius: BorderRadius.circular(16),
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
                      shape: BoxShape.circle,
                      color: Color(0xFFF9FAFB),
                    ),
                    child: child.avatarUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              child.avatarUrl!.startsWith('http')
                                  ? child.avatarUrl!
                                  : ServiceConstants.storageBase +
                                        child.avatarUrl!,
                            ),
                          )
                        : Icon(Icons.person, color: Color(0xFF6B7280)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          child.className,
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
              SizedBox(height: 12),
              Row(
                children: [
                  _buildChildStat(
                    Icons.star,
                    'Level ${child.level} — ${child.xp} XP',
                    Color(0xFFF59E0B),
                  ),
                  SizedBox(width: 16),
                  _buildChildStat(
                    Icons.trending_up,
                    'Aktivitas: ${child.weeklyActivity}% minggu ini',
                    Color(0xFF10B981),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Progress',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildStat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
