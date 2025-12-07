import 'package:flutter/material.dart';
import 'package:keep_it_grow/models/user_model.dart';
import 'package:keep_it_grow/screens/student/student_reward_list_screen.dart';
import 'package:keep_it_grow/screens/student/student_reward_requests_screen.dart';

class RedeemRewardScreen extends StatefulWidget {
  final UserModel user;

  const RedeemRewardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<RedeemRewardScreen> createState() => _RedeemRewardScreenState();
}

class _RedeemRewardScreenState extends State<RedeemRewardScreen>
    with SingleTickerProviderStateMixin {
  late int _coinBalance;

  @override
  void initState() {
    super.initState();
    _coinBalance = widget.user.coin;
  }

  void _onRequestSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request reward berhasil dikirim'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onRequestSpend(int spent) {
    setState(() {
      _coinBalance = (_coinBalance - spent).clamp(0, _coinBalance);
    });
    _onRequestSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('Reward Member'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFF3B82F6),
            labelColor: Color(0xFF1D4ED8),
            unselectedLabelColor: Color(0xFF6B7280),
            tabs: [
              Tab(text: 'Reward'),
              Tab(text: 'Request Saya'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StudentRewardListScreen(
              coin: _coinBalance,
              onRequested: _onRequestSpend,
            ),
            const StudentRewardRequestsScreen(),
          ],
        ),
      ),
    );
  }
}
