import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/student_reward_models.dart';
import 'package:keep_it_grow/services/constants.dart';
import 'package:keep_it_grow/services/student/reward_service.dart';

class StudentRewardRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const StudentRewardRequestDetailScreen({Key? key, required this.requestId})
    : super(key: key);

  @override
  State<StudentRewardRequestDetailScreen> createState() =>
      _StudentRewardRequestDetailScreenState();
}

class _StudentRewardRequestDetailScreenState
    extends State<StudentRewardRequestDetailScreen> {
  final RewardService _rewardService = RewardService();
  late Future<StudentRewardRequest> _requestFuture;

  @override
  void initState() {
    super.initState();
    _requestFuture = _rewardService.getRewardRequestDetail(widget.requestId);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Widget _buildStatusChip(StudentRewardRequest request) {
    final color = _statusColor(request.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            request.statusLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Detail Request'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: FutureBuilder<StudentRewardRequest>(
        future: _requestFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _requestFuture = _rewardService.getRewardRequestDetail(
                          widget.requestId,
                        );
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final request = snapshot.data!;
          final resolvedImage =
              request.reward.imageUrl != null &&
                  request.reward.imageUrl!.isNotEmpty
              ? (request.reward.imageUrl!.startsWith('http')
                    ? request.reward.imageUrl
                    : '${ServiceConstants.storageBase}${request.reward.imageUrl}')
              : null;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFFE5E7EB),
                            backgroundImage: resolvedImage != null
                                ? NetworkImage(resolvedImage)
                                : null,
                            child: resolvedImage == null
                                ? const Icon(
                                    Icons.card_giftcard,
                                    color: Color(0xFF6B7280),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.reward.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  request.reward.type.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(request),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Jumlah',
                        value: '${request.quantity}',
                        icon: Icons.numbers,
                        color: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Total koin',
                        value: '${request.totalCoinCost}',
                        icon: Icons.monetization_on,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Dibuat',
                        value: request.createdAt,
                        icon: Icons.access_time,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Terakhir diperbarui',
                        value: request.updatedAt,
                        icon: Icons.update,
                        color: const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (request.code != null) ...[
                  _SectionCard(
                    title: 'Kode Pengambilan',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.code ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (request.codeExpiresAt != null)
                          Text(
                            'Berlaku sampai: ${request.codeExpiresAt}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _SectionCard(
                  title: 'Status & Timeline',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimelineTile(
                        label: 'Disetujui',
                        value: request.timeline.approvedAt ?? '-',
                        active: request.timeline.approvedAt != null,
                      ),
                      const SizedBox(height: 8),
                      _TimelineTile(
                        label: 'Selesai',
                        value: request.timeline.completedAt ?? '-',
                        active: request.timeline.completedAt != null,
                      ),
                    ],
                  ),
                ),
                if (request.rejectionReason != null &&
                    request.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Alasan Penolakan',
                    child: Text(
                      request.rejectionReason!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFB91C1C),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final String label;
  final String value;
  final bool active;

  const _TimelineTile({
    required this.label,
    required this.value,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle : Icons.radio_button_unchecked,
          color: active ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ],
    );
  }
}
