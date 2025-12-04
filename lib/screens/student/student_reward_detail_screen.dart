import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/student_reward_models.dart';
import 'package:keep_it_grow/services/constants.dart';
import 'package:keep_it_grow/services/student/reward_service.dart';

class StudentRewardDetailScreen extends StatefulWidget {
  final int rewardId;
  final StudentReward? initialReward;
  final int currentCoin;
  final ValueChanged<int>? onRequestSuccess;

  const StudentRewardDetailScreen({
    Key? key,
    required this.rewardId,
    this.initialReward,
    required this.currentCoin,
    this.onRequestSuccess,
  }) : super(key: key);

  @override
  State<StudentRewardDetailScreen> createState() =>
      _StudentRewardDetailScreenState();
}

class _StudentRewardDetailScreenState extends State<StudentRewardDetailScreen> {
  final RewardService _rewardService = RewardService();
  late Future<StudentReward> _rewardFuture;
  int _quantity = 1;
  bool _isSubmitting = false;
  late int _coinBalance;

  @override
  void initState() {
    super.initState();
    _coinBalance = widget.currentCoin;
    _rewardFuture = _loadReward();
  }

  Future<StudentReward> _loadReward() async {
    if (widget.initialReward != null) return widget.initialReward!;
    return _rewardService.getRewardDetail(widget.rewardId);
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'physical':
        return const Color(0xFF10B981);
      case 'digital':
        return const Color(0xFF3B82F6);
      case 'voucher':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<void> _submitRequest(StudentReward reward) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });
    try {
      await _rewardService.requestReward(reward.id, _quantity);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request reward berhasil diajukan'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onRequestSuccess?.call(reward.coinCost * _quantity);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan request: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Detail Reward'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: FutureBuilder<StudentReward>(
        future: _rewardFuture,
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
                        _rewardFuture = _loadReward();
                      });
                    },
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            );
          }

          final reward = snapshot.data!;
          final canRequest = reward.canRequest && reward.isAvailable;
          final availableQuantity = reward.remainingStock > 0
              ? reward.remainingStock
              : reward.stock;
          final totalCost = reward.coinCost * _quantity;
          final coinEnough = _coinBalance >= totalCost;
          final affordable = reward.affordable;
          final disableRequest =
              !canRequest || availableQuantity == 0 || !coinEnough;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RewardHero(reward: reward),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _typeColor(reward.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reward.type.toUpperCase(),
                        style: TextStyle(
                          color: _typeColor(reward.type),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: affordable
                            ? const Color(0xFFECFDF3)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            affordable ? Icons.check_circle : Icons.error,
                            color: affordable
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            coinEnough
                                ? 'Koin cukup'
                                : 'Koin tidak cukup (${reward.coinCost} koin)',
                            style: TextStyle(
                              color: coinEnough
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF991B1B),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Biaya',
                  value: '${reward.coinCost} koin',
                  icon: Icons.monetization_on,
                  iconColor: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Stok',
                  value: '${reward.remainingStock}/${reward.stock} tersedia',
                  icon: Icons.inventory_2,
                  iconColor: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Status',
                  value: reward.isAvailable ? 'Tersedia' : 'Tidak tersedia',
                  icon: Icons.check_circle,
                  iconColor: reward.isAvailable
                      ? const Color(0xFF10B981)
                      : const Color(0xFF9CA3AF),
                ),
                if (reward.validityDays != null) ...[
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Masa berlaku',
                    value: '${reward.validityDays} hari',
                    icon: Icons.schedule,
                    iconColor: const Color(0xFF6366F1),
                  ),
                ],
                if (reward.additionalInfo != null &&
                    reward.additionalInfo!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Info tambahan',
                    body: reward.additionalInfo!,
                  ),
                ],
                const SizedBox(height: 16),
                _QuantitySelector(
                  quantity: _quantity,
                  maxQuantity: availableQuantity > 0 ? availableQuantity : 1,
                  onChanged: (val) {
                    setState(() {
                      _quantity = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: disableRequest || _isSubmitting
                        ? null
                        : () => _submitRequest(reward),
                    icon: const Icon(Icons.card_giftcard),
                    label: Text(
                      _isSubmitting
                          ? 'Memproses...'
                          : 'Ajukan ${reward.coinCost * _quantity} koin',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RewardHero extends StatelessWidget {
  final StudentReward reward;
  const _RewardHero({required this.reward});

  String? _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${ServiceConstants.storageBase}$url';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: reward.imageUrl != null
                ? Image.network(
                    _resolveImageUrl(reward.imageUrl)!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 180,
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Icons.card_giftcard,
                        size: 48,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.monetization_on, color: const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Text(
                  '${reward.coinCost} koin',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                Icon(
                  reward.affordable ? Icons.check_circle : Icons.info,
                  color: reward.affordable
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
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
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Text(
            'Jumlah',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: const Color(0xFF6B7280),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          IconButton(
            onPressed: quantity < maxQuantity
                ? () => onChanged(quantity + 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
            color: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }
}
