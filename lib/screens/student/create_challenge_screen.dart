// screens/student/create_challenge_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/challenges_service.dart';
import '../../services/categories_service.dart';

class CreateChallengeScreen extends StatefulWidget {
  final UserModel user;
  final Map<String, dynamic>? challenge; // Untuk edit mode

  const CreateChallengeScreen({Key? key, required this.user, this.challenge})
    : super(key: key);

  @override
  _CreateChallengeScreenState createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _xpRewardController = TextEditingController();

  int? _selectedCategoryId;
  String? _selectedCategoryName;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isEditMode = false;

  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.challenge != null;
    _loadCategories();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditMode && widget.challenge != null) {
      _titleController.text = widget.challenge!['title'] ?? '';
      _descriptionController.text = widget.challenge!['description'] ?? '';
      _xpRewardController.text = (widget.challenge!['xp_reward'] ?? 0)
          .toString();
      _selectedCategoryName = widget.challenge!['category'] ?? '';

      // Parse dates
      if (widget.challenge!['start_date'] != null) {
        _startDate = DateTime.parse(widget.challenge!['start_date']);
      }
      if (widget.challenge!['end_date'] != null) {
        _endDate = DateTime.parse(widget.challenge!['end_date']);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final data = await CategoriesService.getCategories();
      setState(() {
        _categories = data['data'] ?? [];
      });

      // Set category ID jika dalam mode edit
      if (_isEditMode && _selectedCategoryName != null) {
        final category = _categories.firstWhere(
          (cat) => cat['name'] == _selectedCategoryName,
          orElse: () => null,
        );
        if (category != null) {
          _selectedCategoryId = category['id'];
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kategori: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date jika start date setelah end date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih start date terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(Duration(days: 1)),
      firstDate: _startDate!.add(Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submitChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih kategori challenge'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih tanggal start dan end'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final challengeData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategoryId,
        'xp_reward': int.parse(_xpRewardController.text),
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate!.toIso8601String().split('T')[0],
      };

      if (_isEditMode) {
        await ChallengesService.updateChallenge(
          widget.challenge!['id'],
          challengeData,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await ChallengesService.createChallenge(challengeData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal ${_isEditMode ? 'mengupdate' : 'membuat'} challenge: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Kategori',
          labelStyle: TextStyle(color: Color(0xFF6B7280)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedCategoryId,
            isExpanded: true, // Tambahkan ini
            isDense: true,
            hint: Text(
              'Pilih Kategori',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            items: _categories.map<DropdownMenuItem<int>>((category) {
              return DropdownMenuItem<int>(
                value: category['id'],
                child: Text(
                  category['name'] ?? 'Unknown',
                  style: TextStyle(color: Color(0xFF111827), fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (int? value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: date != null ? '${date.day}/${date.month}/${date.year}' : '',
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF6B7280)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF6B7280)),
        ),
        onTap: onTap,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Pilih $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Challenge' : 'Buat Challenge Baru',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteChallenge,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
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
                            child: Text(
                              _isEditMode
                                  ? 'Edit challenge self-mu'
                                  : 'Buat challenge self baru untuk berkembang',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Form Fields
                    Text(
                      'Informasi Challenge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Title
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Judul Challenge',
                          labelStyle: TextStyle(color: Color(0xFF6B7280)),
                          hintText: 'Contoh: Baca 1 buku per minggu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul challenge harus diisi';
                          }
                          if (value.length < 3) {
                            return 'Judul minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),

                    // Description
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          labelStyle: TextStyle(color: Color(0xFF6B7280)),
                          hintText:
                              'Jelaskan detail challenge yang akan dilakukan...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi challenge harus diisi';
                          }
                          if (value.length < 10) {
                            return 'Deskripsi minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),

                    // Category
                    _buildCategoryDropdown(),
                    SizedBox(height: 16),

                    // XP Reward
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _xpRewardController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'XP Reward',
                          labelStyle: TextStyle(color: Color(0xFF6B7280)),
                          hintText: 'Contoh: 100',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'XP reward harus diisi';
                          }
                          final xp = int.tryParse(value);
                          if (xp == null || xp < 1 || xp > 1000) {
                            return 'XP reward harus antara 1-1000';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),

                    // Dates
                    Text(
                      'Periode Challenge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            'Start Date',
                            _startDate,
                            _selectStartDate,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            'End Date',
                            _endDate,
                            _selectEndDate,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_startDate != null && _endDate != null)
                      Text(
                        'Durasi: ${_endDate!.difference(_startDate!).inDays} hari',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),

                    SizedBox(height: 40),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitChallenge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isEditMode
                                    ? 'UPDATE CHALLENGE'
                                    : 'BUAT CHALLENGE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
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
      setState(() {
        _isLoading = true;
      });

      try {
        await ChallengesService.deleteChallenge(widget.challenge!['id']);
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpRewardController.dispose();
    super.dispose();
  }
}
