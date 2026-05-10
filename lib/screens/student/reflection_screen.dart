import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep_it_grow/models/reflection_template_models.dart';
import 'package:keep_it_grow/models/user_model.dart';
import 'package:keep_it_grow/services/reflection_service.dart';

class ReflectionScreen extends StatefulWidget {
  final UserModel user;

  const ReflectionScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  ActiveReflectionSubmissionContext? _activeContext;
  List<ReflectionSubmissionSummary> _history = [];
  final Map<int, dynamic> _answers = {};

  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';

  ReflectionTemplate? get _template => _activeContext?.template;
  StudentReflectionSubmission? get _submission => _activeContext?.submission;
  bool get _isReadOnly => _submission?.isReadOnly ?? false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        ReflectionService.getActiveReflectionSubmission(),
        ReflectionService.getReflectionTemplateHistory(),
      ]);

      final activeResponse = results[0];
      final historyResponse = results[1];

      final activeData = activeResponse['data'];
      final historyData = historyResponse['data'] as List<dynamic>? ?? [];

      ActiveReflectionSubmissionContext? context;
      if (activeData != null) {
        context = ActiveReflectionSubmissionContext.fromJson(
          Map<String, dynamic>.from(activeData),
        );
      }

      _answers.clear();
      if (context?.submission != null) {
        context!.submission!.answerMap.forEach((key, value) {
          _answers[int.tryParse(key) ?? 0] = value;
        });
      }

      setState(() {
        _activeContext = context;
        _history = historyData
            .map(
              (item) => ReflectionSubmissionSummary.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDraft() async {
    await _submitToApi(isFinalSubmit: false);
  }

  Future<void> _submitFinal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Refleksi'),
        content: const Text(
          'Setelah submit, jawaban tidak bisa diubah lagi. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submitToApi(isFinalSubmit: true);
    }
  }

  Future<void> _submitToApi({required bool isFinalSubmit}) async {
    if (_template == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final payload = {
        'answers': _template!.questions
            .map((question) => {
                  'question_id': question.id,
                  'answer': _answers[question.id],
                })
            .toList(),
      };

      if (isFinalSubmit) {
        await ReflectionService.submitReflectionTemplate(payload);
      } else {
        await ReflectionService.saveReflectionDraft(payload);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFinalSubmit
                ? 'Refleksi berhasil disubmit.'
                : 'Draft refleksi berhasil disimpan.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses refleksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _setAnswer(int questionId, dynamic value) {
    _answers[questionId] = value;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Color(0xFFF59E0B),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Refleksi Diri',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _template?.title ??
                      'Template refleksi aktif akan muncul di sini.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTemplateState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(Icons.event_busy, size: 56, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            'Belum ada template refleksi aktif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Admin belum mengaktifkan template refleksi. Coba lagi nanti.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTemplateCard() {
    final period = _activeContext?.period;
    final status = _submission?.status ?? 'belum_mulai';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _template?.title ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 8),
          if ((_template?.description ?? '').isNotEmpty)
            Text(
              _template!.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF6B7280)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    period?.label ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final config = switch (status) {
      'submitted' => {
          'label': 'Submitted',
          'bg': const Color(0xFFE0F2FE),
          'fg': const Color(0xFF0369A1),
        },
      'draft' => {
          'label': 'Draft',
          'bg': const Color(0xFFFEF3C7),
          'fg': const Color(0xFFB45309),
        },
      _ => {
          'label': 'Belum Mulai',
          'bg': const Color(0xFFF3F4F6),
          'fg': const Color(0xFF4B5563),
        },
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: config['fg'] as Color,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ReflectionTemplateQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if ((question.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        question.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (question.isRequired)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Wajib',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuestionInput(question),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(ReflectionTemplateQuestion question) {
    if (_isReadOnly) {
      return _buildReadOnlyAnswer(question, _answers[question.id]);
    }

    switch (question.type) {
      case 'text':
        return TextFormField(
          key: ValueKey('text_${question.id}'),
          initialValue: (_answers[question.id] ?? '').toString(),
          decoration: _inputDecoration(question.options['placeholder']),
          onChanged: (value) => _setAnswer(question.id, value),
        );
      case 'textarea':
        return TextFormField(
          key: ValueKey('textarea_${question.id}'),
          initialValue: (_answers[question.id] ?? '').toString(),
          maxLines: 5,
          decoration: _inputDecoration(question.options['placeholder']),
          onChanged: (value) => _setAnswer(question.id, value),
        );
      case 'number':
        return TextFormField(
          key: ValueKey('number_${question.id}'),
          initialValue: _answers[question.id]?.toString() ?? '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(question.options['placeholder']),
          onChanged: (value) => _setAnswer(
            question.id,
            value.trim().isEmpty ? null : num.tryParse(value),
          ),
        );
      case 'scale':
      case 'mood_scale':
        return _buildScaleInput(question);
      case 'single_choice':
        return _buildSingleChoiceInput(question);
      case 'multiple_choice':
        return _buildMultipleChoiceInput(question);
      case 'emotion_picker':
        return _buildEmotionPicker(question);
      case 'emotion_table':
        return _buildEmotionTable(question);
      case 'date_range':
        return _buildDateRangeInput(question);
      default:
        return const Text('Tipe pertanyaan belum didukung.');
    }
  }

  InputDecoration _inputDecoration(String? placeholder) {
    return InputDecoration(
      hintText: placeholder,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildScaleInput(ReflectionTemplateQuestion question) {
    final min = (question.options['min'] ?? 1).toDouble();
    final max = (question.options['max'] ?? 5).toDouble();
    final raw = _answers[question.id];
    final value = raw is num ? raw.toDouble() : min;
    final divisions = max > min ? (max - min).toInt() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              (question.options['min_label'] ?? min.toInt().toString()).toString(),
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const Spacer(),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const Spacer(),
            Text(
              (question.options['max_label'] ?? max.toInt().toString()).toString(),
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value.clamp(min, max),
          onChanged: (newValue) {
            setState(() {
              _setAnswer(question.id, newValue.round());
            });
          },
        ),
      ],
    );
  }

  Widget _buildSingleChoiceInput(ReflectionTemplateQuestion question) {
    final choices = (question.options['choices'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final selected = _answers[question.id];

    return Column(
      children: choices.map((choice) {
        return RadioListTile<String>(
          value: choice['value'].toString(),
          groupValue: selected?.toString(),
          title: Text(choice['label']?.toString() ?? choice['value'].toString()),
          onChanged: (value) {
            setState(() {
              _setAnswer(question.id, value);
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceInput(ReflectionTemplateQuestion question) {
    final choices = _readOptionList(question.options['choices']);
    final selected = _readStringList(_answers[question.id]);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: choices.map((choice) {
        final value = choice['value'].toString();
        final isSelected = selected.contains(value);

        return FilterChip(
          selected: isSelected,
          label: Text(choice['label']?.toString() ?? value),
          onSelected: (checked) {
            setState(() {
              if (checked) {
                selected.add(value);
              } else {
                selected.remove(value);
              }
              _setAnswer(question.id, selected.toSet().toList());
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmotionPicker(ReflectionTemplateQuestion question) {
    final choices = _readOptionList(question.options['choices']);
    final allowMultiple = question.options['allow_multiple'] == true;
    final selected = _answers[question.id];
    final selectedList = _readStringList(selected);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: choices.map((choice) {
        final value = choice['value'].toString();
        final label = choice['label']?.toString() ?? value;
        final emoji = choice['emoji']?.toString() ?? '🙂';
        final isSelected = allowMultiple
            ? selectedList.contains(value)
            : selected?.toString() == value;

        return ChoiceChip(
          selected: isSelected,
          label: Text('$emoji  $label'),
          onSelected: (checked) {
            setState(() {
              if (allowMultiple) {
                if (checked) {
                  selectedList.add(value);
                } else {
                  selectedList.remove(value);
                }
                _setAnswer(question.id, selectedList.toSet().toList());
              } else {
                _setAnswer(question.id, checked ? value : null);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmotionTable(ReflectionTemplateQuestion question) {
    final emotions = _readOptionList(question.options['emotions']);
    final rowFields = _readOptionList(question.options['row_fields']);
    final answer = _readMap(_answers[question.id]);

    return Column(
      children: emotions.map((emotion) {
        final emotionKey = emotion['value'].toString();
        final currentRow = _readMap(answer[emotionKey]);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${emotion['emoji'] ?? '🙂'} ${emotion['label'] ?? emotionKey}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...rowFields.map((field) {
                final fieldKey = field['key'].toString();
                final label = field['label']?.toString() ?? fieldKey;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    key: ValueKey('emotion_${question.id}_${emotionKey}_$fieldKey'),
                    initialValue: currentRow[fieldKey]?.toString() ?? '',
                    maxLines: field['type'] == 'textarea' ? 3 : 1,
                    decoration: _inputDecoration(label),
                    onChanged: (value) {
                      final latestAnswer = Map<String, dynamic>.from(
                        _readMap(_answers[question.id]),
                      );
                      final latestRow = _readMap(latestAnswer[emotionKey]);
                      latestRow[fieldKey] = value;
                      latestAnswer[emotionKey] = latestRow;
                      _setAnswer(question.id, latestAnswer);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeInput(ReflectionTemplateQuestion question) {
    final answer = _readMap(_answers[question.id]);

    return Row(
      children: [
        Expanded(
          child: _buildDatePickerField(
            label: question.options['start_label']?.toString() ?? 'Tanggal mulai',
            value: answer['start_date']?.toString(),
            onTap: () async {
              final selected = await _pickDate(answer['start_date']?.toString());
              if (selected == null) return;
              setState(() {
                final latestAnswer = Map<String, dynamic>.from(
                  _readMap(_answers[question.id]),
                );
                latestAnswer['start_date'] = selected;
                _setAnswer(question.id, latestAnswer);
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDatePickerField(
            label: question.options['end_label']?.toString() ?? 'Tanggal selesai',
            value: answer['end_date']?.toString(),
            onTap: () async {
              final selected = await _pickDate(answer['end_date']?.toString());
              if (selected == null) return;
              setState(() {
                final latestAnswer = Map<String, dynamic>.from(
                  _readMap(_answers[question.id]),
                );
                latestAnswer['end_date'] = selected;
                _setAnswer(question.id, latestAnswer);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value == null || value.isEmpty
                  ? 'Pilih tanggal'
                  : _formatDate(value),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickDate(String? currentValue) async {
    final initialDate = currentValue != null && currentValue.isNotEmpty
        ? DateTime.tryParse(currentValue) ?? DateTime.now()
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return null;
    return DateFormat('yyyy-MM-dd').format(picked);
  }

  Widget _buildReadOnlyAnswer(
    ReflectionTemplateQuestion question,
    dynamic answer,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        _formatAnswerForDisplay(question, answer),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF374151),
          height: 1.5,
        ),
      ),
    );
  }

  String _formatAnswerForDisplay(
    ReflectionTemplateQuestion question,
    dynamic answer,
  ) {
    if (answer == null) return 'Belum dijawab';

    if (question.type == 'single_choice') {
      return _resolveChoiceLabel(question, answer.toString());
    }

    if (question.type == 'emotion_picker') {
      final selectedValues = _readStringList(answer);
      if (selectedValues.isEmpty) {
        return 'Belum dijawab';
      }

      return selectedValues
          .map((item) => _resolveChoiceLabel(question, item))
          .join(', ');
    }

    if (question.type == 'multiple_choice') {
      final selectedValues = _readStringList(answer);
      if (selectedValues.isEmpty) {
        return 'Belum dijawab';
      }

      return selectedValues
          .map((item) => _resolveChoiceLabel(question, item.toString()))
          .join(', ');
    }

    if (question.type == 'date_range' && answer is Map) {
      final map = _readMap(answer);
      final startDate = map['start_date']?.toString() ?? '-';
      final endDate = map['end_date']?.toString() ?? '-';
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    }

    if (answer is Map || answer is List) {
      return const JsonEncoder.withIndent('  ').convert(answer);
    }

    return answer.toString();
  }

  String _resolveChoiceLabel(
    ReflectionTemplateQuestion question,
    String value,
  ) {
    final choices = _readOptionList(question.options['choices']);

    for (final choice in choices) {
      if (choice['value']?.toString() == value) {
        final emoji = choice['emoji']?.toString();
        final label = choice['label']?.toString() ?? value;
        return emoji != null ? '$emoji $label' : label;
      }
    }

    return value;
  }

  List<Map<String, dynamic>> _readOptionList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Object>()
        .map((item) => _readMap(item))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _readStringList(dynamic value) {
    if (value == null) {
      return <String>[];
    }

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? <String>[] : <String>[trimmed];
    }

    return <String>[value.toString()];
  }

  Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return DateFormat('dd MMM yyyy').format(date);
  }

  Widget _buildActionButtons() {
    if (_template == null || _isReadOnly) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : _saveDraft,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan Draft'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitFinal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Submit Final'),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Refleksi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        if (_history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Belum ada riwayat refleksi yang sudah disubmit.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          )
        else
          Column(
            children: _history.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    item.templateTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${item.reflectionStartDate ?? '-'}'
                      '${item.reflectionEndDate != null ? ' s/d ${item.reflectionEndDate}' : ''}',
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReflectionHistoryDetailScreen(
                          summary: item,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Refleksi Diri',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Gagal memuat refleksi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      if (_template == null) ...[
                        _buildNoTemplateState(),
                      ] else ...[
                        _buildActiveTemplateCard(),
                        const SizedBox(height: 20),
                        ..._template!.questions
                            .map((question) => _buildQuestionCard(question))
                            .toList(),
                        const SizedBox(height: 4),
                        _buildActionButtons(),
                      ],
                      const SizedBox(height: 28),
                      _buildHistorySection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}

class ReflectionHistoryDetailScreen extends StatefulWidget {
  final ReflectionSubmissionSummary summary;

  const ReflectionHistoryDetailScreen({Key? key, required this.summary})
      : super(key: key);

  @override
  State<ReflectionHistoryDetailScreen> createState() =>
      _ReflectionHistoryDetailScreenState();
}

class _ReflectionHistoryDetailScreenState
    extends State<ReflectionHistoryDetailScreen> {
  ReflectionHistoryDetail? _detail;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ReflectionService.getReflectionTemplateHistoryDetail(
        widget.summary.id,
      );
      final data = response['data'];

      if (data == null) {
        throw Exception('Detail refleksi tidak ditemukan.');
      }

      setState(() {
        _detail = ReflectionHistoryDetail.fromJson(
          Map<String, dynamic>.from(data),
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatAnswer(
    ReflectionTemplateQuestion question,
    Map<String, dynamic> answerMap,
  ) {
    final answer = answerMap[question.id.toString()];

    if (answer == null) return 'Belum dijawab';
    if (question.type == 'date_range' && answer is Map) {
      final map = _readMap(answer);
      return '${map['start_date'] ?? '-'} - ${map['end_date'] ?? '-'}';
    }
    if (answer is Map || answer is List) {
      return const JsonEncoder.withIndent('  ').convert(answer);
    }
    return answer.toString();
  }

  Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Detail Refleksi'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                )
              : _detail == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _detail!.template.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.summary.submittedAt ?? '-',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ..._detail!.template.questions.map((question) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    _formatAnswer(
                                      question,
                                      _detail!.submission.answerMap,
                                    ),
                                    style: const TextStyle(
                                      height: 1.5,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
    );
  }
}
