class StudentReward {
  final int id;
  final String name;
  final String description;
  final int coinCost;
  final int stock;
  final int remainingStock;
  final bool isActive;
  final bool isAvailable;
  final String? imageUrl;
  final String type;
  final int? validityDays;
  final bool canRequest;
  final bool affordable;
  final String? additionalInfo;
  final String? createdAt;

  StudentReward({
    required this.id,
    required this.name,
    required this.description,
    required this.coinCost,
    required this.stock,
    required this.remainingStock,
    required this.isActive,
    required this.isAvailable,
    this.imageUrl,
    required this.type,
    this.validityDays,
    required this.canRequest,
    required this.affordable,
    this.additionalInfo,
    this.createdAt,
  });

  factory StudentReward.fromJson(Map<String, dynamic> json) {
    return StudentReward(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coinCost: json['coin_cost'] ?? 0,
      stock: json['stock'] ?? 0,
      remainingStock: json['remaining_stock'] ?? 0,
      isActive: json['is_active'] ?? false,
      isAvailable: json['is_available'] ?? false,
      imageUrl: json['image_url'],
      type: json['type'] ?? '',
      validityDays: json['validity_days'],
      canRequest: json['can_request'] ?? false,
      affordable: json['affordable'] ?? false,
      additionalInfo: json['additional_info'],
      createdAt: json['created_at'],
    );
  }
}

class StudentRewardSummary {
  final int id;
  final String name;
  final String type;
  final String? imageUrl;
  final int coinCost;

  StudentRewardSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.coinCost,
    this.imageUrl,
  });

  factory StudentRewardSummary.fromJson(Map<String, dynamic> json) {
    return StudentRewardSummary(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['image_url'],
      coinCost: json['coin_cost'] ?? 0,
    );
  }
}

class StudentRewardRequestTimeline {
  final String? approvedAt;
  final String? completedAt;

  StudentRewardRequestTimeline({
    this.approvedAt,
    this.completedAt,
  });

  factory StudentRewardRequestTimeline.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StudentRewardRequestTimeline();
    return StudentRewardRequestTimeline(
      approvedAt: json['approved_at'],
      completedAt: json['completed_at'],
    );
  }
}

class StudentRewardRequest {
  final int id;
  final StudentRewardSummary reward;
  final int quantity;
  final int totalCoinCost;
  final String status;
  final String statusLabel;
  final String? code;
  final String? codeExpiresAt;
  final String? rejectionReason;
  final String createdAt;
  final String updatedAt;
  final StudentRewardRequestTimeline timeline;

  StudentRewardRequest({
    required this.id,
    required this.reward,
    required this.quantity,
    required this.totalCoinCost,
    required this.status,
    required this.statusLabel,
    required this.createdAt,
    required this.updatedAt,
    this.code,
    this.codeExpiresAt,
    this.rejectionReason,
    StudentRewardRequestTimeline? timeline,
  }) : timeline = timeline ?? StudentRewardRequestTimeline();

  factory StudentRewardRequest.fromJson(Map<String, dynamic> json) {
    return StudentRewardRequest(
      id: json['id'] ?? 0,
      reward: StudentRewardSummary.fromJson(json['reward'] ?? {}),
      quantity: json['quantity'] ?? 0,
      totalCoinCost: json['total_coin_cost'] ?? 0,
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      code: json['code'],
      codeExpiresAt: json['code_expires_at'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      timeline: StudentRewardRequestTimeline.fromJson(json['timeline']),
    );
  }
}
