import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/habits_service.dart';
import '../../services/categories_service.dart';

class CreateHabitScreen extends StatefulWidget {
  final UserModel user;
  final Map<String, dynamic>? habit; // Untuk edit mode

  const CreateHabitScreen({Key? key, required this.user, this.habit})
    : super(key: key);

  @override
  _CreateHabitScreenState createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _xpRewardController = TextEditingController();

  int? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedPeriod;
  bool _isLoading = false;
  bool _isEditMode = false;

  DateTime? _startDate;
  DateTime? _endDate;

  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.habit != null;
    _loadCategories();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditMode && widget.habit != null) {
      _titleController.text = widget.habit!['title'] ?? '';
      _descriptionController.text = widget.habit!['description'] ?? '';
      _xpRewardController.text = (widget.habit!['xp_reward'] ?? 0).toString();
      _selectedCategoryName = widget.habit!['category'] ?? '';
      _selectedPeriod = widget.habit!['period'] ?? 'daily';
      
      // Initialize dates
      if (widget.habit!['start_date'] != null) {
        _startDate = DateTime.parse(widget.habit!['start_date']);
      }
      if (widget.habit!['end_date'] != null) {
        _endDate = DateTime.parse(widget.habit!['end_date']);
      }
    } else {
      _selectedPeriod = 'daily'; // Default value
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(Duration(days: 30)); // Default 30 days
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
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Jika end date sebelum start date, update end date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked.add(Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate?.add(Duration(days: 30)) ?? DateTime.now().add(Duration(days: 30))),
      firstDate: _startDate?.add(Duration(days: 1)) ?? DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _submitHabit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih kategori habit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih periode habit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih tanggal mulai dan berakhir'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final habitData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategoryId,
        'xp_reward': int.parse(_xpRewardController.text),
        'period': _selectedPeriod,
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate!.toIso8601String().split('T')[0],
      };

      if (_isEditMode) {
        await HabitsService.updateHabit(
          widget.habit!['id'],
          habitData,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habit berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await HabitsService.createHabit(habitData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habit berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal ${_isEditMode ? 'mengupdate' : 'membuat'} habit: $e',
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
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
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
          child: Text(
            date != null 
              ? '${date.day}/${date.month}/${date.year}'
              : 'Pilih Tanggal',
            style: TextStyle(
              color: date != null ? Color(0xFF111827) : Color(0xFF9CA3AF),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // ... (Kode lainnya seperti _buildCategoryDropdown, _buildPeriodDropdown, _deleteHabit tetap sama)

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
            isExpanded: true,
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

  Widget _buildPeriodDropdown() {
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
          labelText: 'Periode',
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
          child: DropdownButton<String>(
            value: _selectedPeriod,
            isExpanded: true,
            isDense: true,
            items: [
              DropdownMenuItem(
                value: 'daily',
                child: Text('Harian', style: TextStyle(color: Color(0xFF111827))),
              ),
              DropdownMenuItem(
                value: 'weekly',
                child: Text('Mingguan', style: TextStyle(color: Color(0xFF111827))),
              ),
            ],
            onChanged: (String? value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Habit'),
        content: Text('Apakah Anda yakin ingin menghapus habit ini?'),
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
        await HabitsService.deleteHabit(widget.habit!['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habit berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus habit: $e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Habit' : 'Buat Habit Baru',
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
              onPressed: _deleteHabit,
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
                            Icons.checklist_rounded,
                            size: 40,
                            color: Color(0xFF3B82F6),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _isEditMode
                                  ? 'Edit habit self-mu'
                                  : 'Buat habit self baru untuk berkembang',
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
                      'Informasi Habit',
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
                          labelText: 'Judul Habit',
                          labelStyle: TextStyle(color: Color(0xFF6B7280)),
                          hintText: 'Contoh: Baca buku 15 menit',
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
                            return 'Judul habit harus diisi';
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
                          hintText: 'Jelaskan detail habit yang akan dilakukan...',
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
                            return 'Deskripsi habit harus diisi';
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

                    // Period
                    _buildPeriodDropdown(),
                    SizedBox(height: 16),

                    // Start Date
                    _buildDateField(
                      'Tanggal Mulai',
                      _startDate,
                      _selectStartDate,
                    ),
                    SizedBox(height: 16),

                    // End Date
                    _buildDateField(
                      'Tanggal Berakhir',
                      _endDate,
                      _selectEndDate,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Habit hanya akan aktif dalam rentang tanggal yang dipilih',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
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
                          hintText: 'Contoh: 10',
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
                          if (xp == null || xp < 1 || xp > 100) {
                            return 'XP reward harus antara 1-100';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'XP reward akan diberikan setiap kali habit diselesaikan',
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
                        onPressed: _isLoading ? null : _submitHabit,
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
                                    ? 'UPDATE HABIT'
                                    : 'BUAT HABIT',
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpRewardController.dispose();
    super.dispose();
  }
}