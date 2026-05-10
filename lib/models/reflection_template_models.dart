class ReflectionTemplate {
  final int id;
  final String title;
  final String? description;
  final String periodType;
  final bool isActive;
  final List<ReflectionTemplateQuestion> questions;

  const ReflectionTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.periodType,
    required this.isActive,
    required this.questions,
  });

  factory ReflectionTemplate.fromJson(Map<String, dynamic> json) {
    return ReflectionTemplate(
      id: _asInt(json['id']),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      periodType: (json['period_type'] ?? 'daily').toString(),
      isActive: json['is_active'] == true,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map(
            (item) => ReflectionTemplateQuestion.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class ReflectionTemplateQuestion {
  final int id;
  final String label;
  final String? description;
  final String type;
  final Map<String, dynamic> options;
  final bool isRequired;
  final int orderNumber;

  const ReflectionTemplateQuestion({
    required this.id,
    required this.label,
    required this.description,
    required this.type,
    required this.options,
    required this.isRequired,
    required this.orderNumber,
  });

  factory ReflectionTemplateQuestion.fromJson(Map<String, dynamic> json) {
    return ReflectionTemplateQuestion(
      id: _asInt(json['id']),
      label: (json['label'] ?? '').toString(),
      description: json['description']?.toString(),
      type: (json['type'] ?? 'textarea').toString(),
      options: _asMap(json['options']),
      isRequired: json['is_required'] == true,
      orderNumber: _asInt(json['order_number']),
    );
  }
}

class ReflectionAssignment {
  final String assignableType;
  final int? assignableId;
  final String? startDate;
  final String? endDate;

  const ReflectionAssignment({
    required this.assignableType,
    required this.assignableId,
    required this.startDate,
    required this.endDate,
  });

  factory ReflectionAssignment.fromJson(Map<String, dynamic> json) {
    return ReflectionAssignment(
      assignableType: (json['assignable_type'] ?? '').toString(),
      assignableId: json['assignable_id'] == null
          ? null
          : _asInt(json['assignable_id']),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
    );
  }
}

class ReflectionPeriod {
  final String? startDate;
  final String? endDate;
  final String label;

  const ReflectionPeriod({
    required this.startDate,
    required this.endDate,
    required this.label,
  });

  factory ReflectionPeriod.fromJson(Map<String, dynamic> json) {
    return ReflectionPeriod(
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}

class StudentReflectionSubmission {
  final int id;
  final int templateId;
  final String status;
  final String? reflectionStartDate;
  final String? reflectionEndDate;
  final String? submittedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<ReflectionAnswerItem> answers;
  final Map<String, dynamic> answerMap;

  const StudentReflectionSubmission({
    required this.id,
    required this.templateId,
    required this.status,
    required this.reflectionStartDate,
    required this.reflectionEndDate,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.answers,
    required this.answerMap,
  });

  bool get isReadOnly => status == 'submitted' || status == 'analyzed';

  factory StudentReflectionSubmission.fromJson(Map<String, dynamic> json) {
    return StudentReflectionSubmission(
      id: _asInt(json['id']),
      templateId: _asInt(json['template_id']),
      status: (json['status'] ?? 'draft').toString(),
      reflectionStartDate: json['reflection_start_date']?.toString(),
      reflectionEndDate: json['reflection_end_date']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map(
            (item) => ReflectionAnswerItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      answerMap: _asMap(json['answer_map']),
    );
  }
}

class ReflectionAnswerItem {
  final int questionId;
  final dynamic answer;

  const ReflectionAnswerItem({
    required this.questionId,
    required this.answer,
  });

  factory ReflectionAnswerItem.fromJson(Map<String, dynamic> json) {
    return ReflectionAnswerItem(
      questionId: _asInt(json['question_id']),
      answer: json['answer'],
    );
  }
}

class ReflectionSubmissionSummary {
  final int id;
  final int templateId;
  final String templateTitle;
  final String status;
  final String? reflectionStartDate;
  final String? reflectionEndDate;
  final String? submittedAt;
  final String? updatedAt;

  const ReflectionSubmissionSummary({
    required this.id,
    required this.templateId,
    required this.templateTitle,
    required this.status,
    required this.reflectionStartDate,
    required this.reflectionEndDate,
    required this.submittedAt,
    required this.updatedAt,
  });

  factory ReflectionSubmissionSummary.fromJson(Map<String, dynamic> json) {
    return ReflectionSubmissionSummary(
      id: _asInt(json['id']),
      templateId: _asInt(json['template_id']),
      templateTitle: (json['template_title'] ?? '-').toString(),
      status: (json['status'] ?? '').toString(),
      reflectionStartDate: json['reflection_start_date']?.toString(),
      reflectionEndDate: json['reflection_end_date']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class ActiveReflectionSubmissionContext {
  final ReflectionTemplate template;
  final ReflectionAssignment? assignment;
  final ReflectionPeriod? period;
  final StudentReflectionSubmission? submission;

  const ActiveReflectionSubmissionContext({
    required this.template,
    required this.assignment,
    required this.period,
    required this.submission,
  });

  factory ActiveReflectionSubmissionContext.fromJson(Map<String, dynamic> json) {
    return ActiveReflectionSubmissionContext(
      template: ReflectionTemplate.fromJson(
        Map<String, dynamic>.from(json['template'] as Map),
      ),
      assignment: json['assignment'] == null
          ? null
          : ReflectionAssignment.fromJson(
              Map<String, dynamic>.from(json['assignment'] as Map),
            ),
      period: json['period'] == null
          ? null
          : ReflectionPeriod.fromJson(
              Map<String, dynamic>.from(json['period'] as Map),
            ),
      submission: json['submission'] == null
          ? null
          : StudentReflectionSubmission.fromJson(
              Map<String, dynamic>.from(json['submission'] as Map),
            ),
    );
  }
}

class ReflectionHistoryDetail {
  final ReflectionTemplate template;
  final StudentReflectionSubmission submission;

  const ReflectionHistoryDetail({
    required this.template,
    required this.submission,
  });

  factory ReflectionHistoryDetail.fromJson(Map<String, dynamic> json) {
    return ReflectionHistoryDetail(
      template: ReflectionTemplate.fromJson(
        Map<String, dynamic>.from(json['template'] as Map),
      ),
      submission: StudentReflectionSubmission.fromJson(
        Map<String, dynamic>.from(json['submission'] as Map),
      ),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return <String, dynamic>{};
}
