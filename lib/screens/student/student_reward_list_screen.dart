import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/student_reward_models.dart';
import 'package:keep_it_grow/screens/student/student_reward_detail_screen.dart';
import 'package:keep_it_grow/services/student/reward_service.dart';
import 'package:keep_it_grow/services/constants.dart';

class StudentRewardListScreen extends StatefulWidget {
  final int coin;
  final ValueChanged<int>? onRequested;

  const StudentRewardListScreen({
    Key? key,
    required this.coin,
    this.onRequested,
  }) : super(key: key);

  @override
  State<StudentRewardListScreen> createState() =>
      _StudentRewardListScreenState();
}

class _StudentRewardListScreenState extends State<StudentRewardListScreen> {
  final RewardService _rewardService = RewardService();
  late Future<List<StudentReward>> _rewardsFuture;
  late int _coinBalance;
  String _search = '';
  String _typeFilter = 'all';
  bool _affordableOnly = false;

  @override
  void initState() {
    super.initState();
    _coinBalance = widget.coin;
    _loadRewards();
  }

  void _loadRewards() {
    setState(() {
      _rewardsFuture = _rewardService.getRewards(
        search: _search,
        type: _typeFilter,
        affordable: _affordableOnly,
      );
    });
  }

  void _handleSpend(int coinSpent) {
    setState(() {
      _coinBalance = (_coinBalance - coinSpent).clamp(0, _coinBalance);
    });
    widget.onRequested?.call(coinSpent);
  }

  String? _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;

    final base = ServiceConstants.storageBase;
    if (url.startsWith('/')) {
      url = url.substring(1);
    }
    if (base.endsWith('/')) {
      return '$base$url';
    }
    return '$base/$url';
  }

  Widget _buildRewardImage(String? url) {
    final resolved = _resolveImageUrl(url);
    return SizedBox(
      width: 70,
      height: 70,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: resolved != null
            ? Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Color(0xFF9CA3AF),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFFF3F4F6),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : Container(
                color: const Color(0xFFF3F4F6),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Color(0xFF9CA3AF),
                ),
              ),
      ),
    );
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

  Widget _buildRewardItem(StudentReward reward, BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 400;
    final coinEnough = _coinBalance >= reward.coinCost;
    final canRequest =
        reward.canRequest &&
        reward.isAvailable &&
        reward.affordable &&
        coinEnough;

    // Widget detail dengan overflow protection
    Widget detailWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris pertama: Nama + Type
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                reward.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _typeColor(reward.type).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getTypeDisplay(reward.type),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _typeColor(reward.type),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Deskripsi
        Text(
          reward.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 8),
        // Baris ketiga: Koin + Stock
        Row(
          children: [
            const Icon(
              Icons.monetization_on,
              size: 16,
              color: Color(0xFFF59E0B),
            ),
            const SizedBox(width: 4),
            Text(
              '${reward.coinCost} koin',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const Spacer(),
            if (reward.remainingStock <= 5)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sisa ${reward.remainingStock}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );

    // Tombol action
    Widget actionButton = SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: canRequest
            ? () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentRewardDetailScreen(
                      rewardId: reward.id,
                      initialReward: reward,
                      currentCoin: _coinBalance,
                      onRequestSuccess: (spent) {
                        _handleSpend(spent);
                        _loadRewards();
                      },
                    ),
                  ),
                );
                if (result == true) {
                  _loadRewards();
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canRequest
              ? const Color(0xFF3B82F6)
              : const Color(0xFF9CA3AF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          canRequest ? 'Request' : 'Tidak bisa',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );

    // Layout berdasarkan lebar layar
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRewardImage(reward.imageUrl),
              const SizedBox(width: 12),
              Expanded(child: detailWidget),
            ],
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: actionButton),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRewardImage(reward.imageUrl),
          const SizedBox(width: 12),
          Expanded(child: detailWidget),
          const SizedBox(width: 12),
          actionButton,
        ],
      );
    }
  }

  String _getTypeDisplay(String type) {
    switch (type) {
      case 'physical':
        return 'PHYSICAL';
      case 'digital':
        return 'DIGITAL';
      case 'voucher':
        return 'VOUCHER';
      default:
        return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(
          coin: _coinBalance,
          onSearch: (val) {
            _search = val;
            _loadRewards();
          },
          typeFilter: _typeFilter,
          onTypeChanged: (val) {
            _typeFilter = val;
            _loadRewards();
          },
          affordableOnly: _affordableOnly,
          onAffordableChanged: (val) {
            _affordableOnly = val;
            _loadRewards();
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _loadRewards(),
            child: FutureBuilder<List<StudentReward>>(
              future: _rewardsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(child: Text('Error: ${snapshot.error}')),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton(
                          onPressed: _loadRewards,
                          child: const Text('Coba Lagi'),
                        ),
                      ),
                    ],
                  );
                }
                final rewards = snapshot.data ?? [];
                if (rewards.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'Belum ada reward tersedia',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentRewardDetailScreen(
                                rewardId: reward.id,
                                initialReward: reward,
                                currentCoin: _coinBalance,
                                onRequestSuccess: (spent) {
                                  _handleSpend(spent);
                                  _loadRewards();
                                },
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadRewards();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return _buildRewardItem(reward, constraints);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatefulWidget {
  final int coin;
  final ValueChanged<String> onSearch;
  final String typeFilter;
  final ValueChanged<String> onTypeChanged;
  final bool affordableOnly;
  final ValueChanged<bool> onAffordableChanged;

  const _Header({
    required this.coin,
    required this.onSearch,
    required this.typeFilter,
    required this.onTypeChanged,
    required this.affordableOnly,
    required this.onAffordableChanged,
  });

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koin Kamu',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    Text(
                      '${widget.coin}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.card_giftcard, color: Color(0xFF3B82F6)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari reward...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: widget.onSearch,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TypeChip(
                  label: 'Semua',
                  value: 'all',
                  current: widget.typeFilter,
                  onSelected: widget.onTypeChanged,
                ),
                _TypeChip(
                  label: 'Physical',
                  value: 'physical',
                  current: widget.typeFilter,
                  onSelected: widget.onTypeChanged,
                ),
                _TypeChip(
                  label: 'Digital',
                  value: 'digital',
                  current: widget.typeFilter,
                  onSelected: widget.onTypeChanged,
                ),
                _TypeChip(
                  label: 'Voucher',
                  value: 'voucher',
                  current: widget.typeFilter,
                  onSelected: widget.onTypeChanged,
                ),
                FilterChip(
                  label: const Text('Koin cukup'),
                  selected: widget.affordableOnly,
                  onSelected: (val) => widget.onAffordableChanged(val),
                  selectedColor: const Color(0xFF10B981).withOpacity(0.16),
                  checkmarkColor: const Color(0xFF065F46),
                  labelStyle: TextStyle(
                    color: widget.affordableOnly
                        ? const Color(0xFF065F46)
                        : const Color(0xFF4B5563),
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: const Color(0xFFF3F4F6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onSelected;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(value),
        selectedColor: const Color(0xFF3B82F6).withOpacity(0.15),
        labelStyle: TextStyle(
          color: selected ? const Color(0xFF1D4ED8) : const Color(0xFF4B5563),
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: const Color(0xFFF3F4F6),
      ),
    );
  }
}
