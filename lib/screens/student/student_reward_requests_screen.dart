import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/student_reward_models.dart';
import 'package:keep_it_grow/screens/student/student_reward_request_detail_screen.dart';
import 'package:keep_it_grow/services/constants.dart';
import 'package:keep_it_grow/services/student/reward_service.dart';

class StudentRewardRequestsScreen extends StatefulWidget {
  const StudentRewardRequestsScreen({Key? key}) : super(key: key);

  @override
  State<StudentRewardRequestsScreen> createState() =>
      _StudentRewardRequestsScreenState();
}

class _StudentRewardRequestsScreenState
    extends State<StudentRewardRequestsScreen> {
  final RewardService _rewardService = RewardService();
  late Future<List<StudentRewardRequest>> _requestsFuture;
  String _statusFilter = 'all';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _requestsFuture = _rewardService.getRewardRequests(
        status: _statusFilter,
        search: _search,
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterBar(
          status: _statusFilter,
          onStatusChanged: (val) {
            _statusFilter = val;
            _loadRequests();
          },
          onSearchChanged: (val) {
            _search = val;
            _loadRequests();
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _loadRequests(),
            child: FutureBuilder<List<StudentRewardRequest>>(
              future: _requestsFuture,
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
                          onPressed: _loadRequests,
                          child: const Text('Coba Lagi'),
                        ),
                      ),
                    ],
                  );
                }

                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'Belum ada request reward',
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
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final color = _statusColor(request.status);
                    final resolvedImage =
                        request.reward.imageUrl != null &&
                            request.reward.imageUrl!.isNotEmpty
                        ? (request.reward.imageUrl!.startsWith('http')
                              ? request.reward.imageUrl
                              : '${ServiceConstants.storageBase}${request.reward.imageUrl}')
                        : null;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF3F4F6),
                          ),
                          child: resolvedImage != null
                              ? ClipOval(
                                  child: Image.network(
                                    resolvedImage,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.card_giftcard,
                                  color: Color(0xFF6B7280),
                                ),
                        ),
                        title: Text(
                          request.reward.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jumlah: ${request.quantity}  •  ${request.totalCoinCost} koin',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      request.statusLabel,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                request.createdAt,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF9CA3AF),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentRewardRequestDetailScreen(
                                    requestId: request.id,
                                  ),
                            ),
                          );
                          _loadRequests();
                        },
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

class _FilterBar extends StatefulWidget {
  final String status;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchChanged;

  const _FilterBar({
    required this.status,
    required this.onStatusChanged,
    required this.onSearchChanged,
  });

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari request',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _StatusChip(
                  label: 'Semua',
                  value: 'all',
                  current: widget.status,
                  onSelected: widget.onStatusChanged,
                ),
                _StatusChip(
                  label: 'Pending',
                  value: 'pending',
                  current: widget.status,
                  onSelected: widget.onStatusChanged,
                ),
                _StatusChip(
                  label: 'Disetujui',
                  value: 'approved',
                  current: widget.status,
                  onSelected: widget.onStatusChanged,
                ),
                _StatusChip(
                  label: 'Selesai',
                  value: 'completed',
                  current: widget.status,
                  onSelected: widget.onStatusChanged,
                ),
                _StatusChip(
                  label: 'Ditolak',
                  value: 'rejected',
                  current: widget.status,
                  onSelected: widget.onStatusChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onSelected;

  const _StatusChip({
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
