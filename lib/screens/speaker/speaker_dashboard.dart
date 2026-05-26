// lib/screens/speaker/speaker_dashboard.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/avatar_utils.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../speaker/go_live_screen.dart';
import '../speaker/speaker_earnings_screen.dart';
import '../speaker/speaker_kyc_screen.dart';
import '../speaker/speaker_profile_screen.dart';
import '../listener/listener_connect_screen.dart';

class SpeakerDashboard extends StatefulWidget {
  final UserModel currentUser;
  const SpeakerDashboard({super.key, required this.currentUser});

  @override
  State<SpeakerDashboard> createState() => _SpeakerDashboardState();
}

class _SpeakerDashboardState extends State<SpeakerDashboard> {
  int _selectedIndex = 0;
  final FirestoreService _fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _fs.getCurrentUserStream(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.currentUser;
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1A),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(user),
              ListenerConnectScreen(currentUser: user),
              SpeakerEarningsScreen(currentUser: user),
              SpeakerProfileScreen(currentUser: user),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _selectedIndex == 0 ? _buildGoLiveButton(user) : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _buildHomeTab(UserModel user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(user),
            const SizedBox(height: 20),
            if (user.kycStatus != 'approved') _buildKycBanner(user),
            const SizedBox(height: 16),
            _buildEarningsCard(user),
            const SizedBox(height: 16),
            _buildStatsRow(user),
            const SizedBox(height: 20),
            _buildRecentGifts(user),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(user.name)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, ${user.name.split(' ').first}! 🎙️',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(user.isLive ? '🔴 You are LIVE' : '⚫ Offline',
                  style: TextStyle(
                    color: user.isLive ? Colors.red : Colors.white54,
                    fontSize: 12, fontWeight: user.isLive ? FontWeight.bold : FontWeight.normal,
                  )),
            ],
          ),
        ),
        // Notification bell
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 20),
        ),
      ],
    );
  }

  Widget _buildKycBanner(UserModel user) {
    Color bannerColor;
    String title, subtitle, btnText;
    IconData icon;

    switch (user.kycStatus) {
      case 'pending':
        bannerColor = Colors.orange;
        title = 'KYC Under Review';
        subtitle = 'We\'re verifying your details. Usually takes 24 hours.';
        btnText = 'View Status';
        icon = Icons.hourglass_top;
        break;
      case 'rejected':
        bannerColor = Colors.red;
        title = 'KYC Rejected';
        subtitle = 'Your documents need re-submission. Please update.';
        btnText = 'Resubmit';
        icon = Icons.error_outline;
        break;
      default:
        bannerColor = Colors.purple;
        title = 'Complete KYC to Withdraw';
        subtitle = 'Verify your identity to start withdrawing earnings.';
        btnText = 'Start KYC';
        icon = Icons.verified_user_outlined;
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => SpeakerKycScreen(currentUser: user),
      )),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bannerColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bannerColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: bannerColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: bannerColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bannerColor, borderRadius: BorderRadius.circular(20),
              ),
              child: Text(btnText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E57C2), Color(0xFFE94057)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${user.earningsInr.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('(${user.earningTokens} tokens)',
                    style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SpeakerEarningsScreen(currentUser: user),
                  )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('View Earnings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: user.kycStatus == 'approved'
                      ? () => _showWithdrawDialog(user)
                      : () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => SpeakerKycScreen(currentUser: user))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: user.kycStatus == 'approved' ? Colors.white : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        user.kycStatus == 'approved' ? 'Withdraw' : '🔒 Withdraw',
                        style: TextStyle(
                          color: user.kycStatus == 'approved' ? Colors.purple : Colors.white54,
                          fontWeight: FontWeight.bold, fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Row(
      children: [
        _miniStat('${user.totalCalls}', 'Total Calls', Icons.phone),
        const SizedBox(width: 10),
        _miniStat('${user.followers}', 'Followers', Icons.favorite),
        const SizedBox(width: 10),
        _miniStat(user.rating > 0 ? user.rating.toStringAsFixed(1) : 'New', 'Rating', Icons.star),
      ],
    );
  }

  Widget _miniStat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryPink, size: 18),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGifts(UserModel user) {
    if (!user.isLive && user.currentRoomId == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: const Column(
          children: [
            Text('🎁', style: TextStyle(fontSize: 36)),
            SizedBox(height: 12),
            Text('Go live to start receiving gifts!',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('Tap the Go Live button below',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fs.getRoomGifts(user.currentRoomId ?? ''),
      builder: (context, snap) {
        final gifts = snap.data ?? [];
        if (gifts.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Gifts 🎁',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...gifts.take(5).map((g) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(g['giftEmoji'] ?? '🎁', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${g['fromName']} sent ${g['giftName']}',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 12)),
                      Text('+${((g['tokens'] as int) * 0.5).floor()}',
                          style: const TextStyle(color: Color(0xFFFFAB00), fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildGoLiveButton(UserModel user) {
    return GestureDetector(
      onTap: () {
        if (user.isLive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are already live!'), backgroundColor: Colors.orange),
          );
          return;
        }
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => GoLiveScreen(currentUser: user),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          gradient: user.isLive
              ? const LinearGradient(colors: [Colors.red, Colors.redAccent])
              : const LinearGradient(colors: [AppColors.primaryPink, AppColors.secondaryPink]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.4),
              blurRadius: 16, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(user.isLive ? Icons.stop : Icons.live_tv, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(user.isLive ? 'End Live' : '🔴 Go Live',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(UserModel user) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Withdraw Earnings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Available: ${user.earningTokens} tokens = ₹${user.earningsInr.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter token amount',
                labelStyle: const TextStyle(color: Colors.white54),
                prefixText: '🪙 ',
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryPink)),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Minimum withdrawal: 1000 tokens (₹500)', style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final tokens = int.tryParse(controller.text) ?? 0;
                  Navigator.pop(context);
                  try {
                    await _fs.requestWithdrawal(tokens);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Withdrawal request submitted! We\'ll process within 24 hours.'),
                        backgroundColor: Colors.green,
                      ));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Request Withdrawal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,     'label': 'Home'},
      {'icon': Icons.people_outline,   'label': 'Connect'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Earnings'},
      {'icon': Icons.person_outline,   'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryPink.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i]['icon'] as IconData,
                          color: selected ? AppColors.primaryPink : Colors.white38, size: 22),
                      const SizedBox(height: 3),
                      Text(items[i]['label'] as String,
                          style: TextStyle(
                            color: selected ? AppColors.primaryPink : Colors.white38,
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
