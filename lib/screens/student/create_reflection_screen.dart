import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/user_model.dart';
import 'package:keep_it_grow/services/reflection_service.dart';
import 'package:intl/intl.dart';

class CreateReflectionScreen extends StatefulWidget {
  final UserModel user;
  final Map<String, dynamic>? reflection; // Untuk edit mode

  const CreateReflectionScreen({Key? key, required this.user, this.reflection})
    : super(key: key);

  @override
  _CreateReflectionScreenState createState() => _CreateReflectionScreenState();
}

class _CreateReflectionScreenState extends State<CreateReflectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bodyController = TextEditingController();

  String? _selectedMood;
  bool _isLoading = false;
  bool _isEditMode = false;
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> _moods = [
    {'value': 'happy', 'label': 'Senang', 'icon': Icons.sentiment_very_satisfied, 'color': Color(0xFF10B981)},
    {'value': 'neutral', 'label': 'Biasa', 'icon': Icons.sentiment_neutral, 'color': Color(0xFFF59E0B)},
    {'value': 'sad', 'label': 'Sedih', 'icon': Icons.sentiment_very_dissatisfied, 'color': Color(0xFF3B82F6)},
    {'value': 'angry', 'label': 'Marah', 'icon': Icons.sentiment_very_dissatisfied, 'color': Color(0xFFEF4444)},
    {'value': 'tired', 'label': 'Lelah', 'icon': Icons.sentiment_dissatisfied, 'color': Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.reflection != null;
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditMode && widget.reflection != null) {
      final reflection = widget.reflection!;
      _bodyController.text = reflection['body'] ?? '';
      _selectedMood = reflection['mood'] ?? 'neutral';
      
      if (reflection['date'] != null) {
        _selectedDate = DateTime.parse(reflection['date']);
      }
    } else {
      _selectedMood = 'neutral'; // Default mood
    }
  }

  
  Future<void> _submitReflection() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih mood untuk refleksi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reflectionData = {
        'mood': _selectedMood,
        'body': _bodyController.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };

      if (_isEditMode) {
        await ReflectionService.updateReflection(
          widget.reflection!['id'],
          reflectionData,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refleksi berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await ReflectionService.createReflection(reflectionData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refleksi berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true); // Return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal ${_isEditMode ? 'mengupdate' : 'membuat'} refleksi: $e',
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bagaimana perasaanmu hari ini?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood['value'];
                  });
                },
                child: Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? (mood['color'] as Color).withOpacity(0.2)
                      : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                        ? mood['color'] as Color 
                        : Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mood['icon'] as IconData,
                        color: mood['color'] as Color,
                        size: 24,
                      ),
                      SizedBox(height: 6),
                      Text(
                        mood['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF6B7280), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Refleksi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Refleksi' : 'Refleksi Baru',
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
                          colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.psychology_rounded,
                            size: 40,
                            color: Color(0xFFF59E0B),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _isEditMode
                                  ? 'Edit refleksi dan perasaanmu'
                                  : 'Tuliskan perasaan dan pembelajaranmu hari ini',
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

                    // Mood Selector
                    _buildMoodSelector(),
                    SizedBox(height: 24),

                    // Date Picker
                    _buildDatePicker(),
                    SizedBox(height: 16),

                    // body
                    Text(
                      'Isi Refleksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 8),
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
                        controller: _bodyController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Tuliskan perasaan, pembelajaran, atau pencapaianmu hari ini...',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
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
                            return 'Isi refleksi harus diisi';
                          }
                          if (value.length < 10) {
                            return 'Isi refleksi minimal 10 karakter';
                          }
                          if (value.length > 1000) {
                            return 'Isi refleksi maksimal 1000 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${_bodyController.text.length}/1000',
                          style: TextStyle(
                            color: _bodyController.text.length > 1000 
                              ? Colors.red 
                              : Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40),

                    // Submit Button
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
                        onPressed: _isLoading ? null : _submitReflection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF59E0B),
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
                                    ? 'UPDATE REFLEKSI'
                                    : 'SIMPAN REFLEKSI',
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
    _bodyController.dispose();
    super.dispose();
  }
}