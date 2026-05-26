// lib/screens/speaker/speaker_earnings_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class SpeakerEarningsScreen extends StatelessWidget {
  final UserModel currentUser;
  const SpeakerEarningsScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Earnings 💰',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Total earnings card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7E57C2), Color(0xFFE94057)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('₹${currentUser.earningsInr.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    Text('${currentUser.earningTokens} tokens × ₹0.50',
                        style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total Withdrawn: ₹${(currentUser.totalWithdrawn * 0.5).toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // How earnings work
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How Earnings Work 📊',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    ...[
                      '🎁  Listener sends 100 token gift',
                      '💰  You earn 50 tokens (50%)',
                      '🏦  Bondly earns 50 tokens (50%)',
                      '💵  1 token = ₹0.50 for you',
                      '📤  Minimum withdrawal: ₹500',
                    ].map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Withdrawal history
              const Text('Withdrawal History',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: fs.getWithdrawalHistory(),
                builder: (context, snap) {
                  final withdrawals = snap.data ?? [];
                  if (withdrawals.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('No withdrawals yet',
                            style: TextStyle(color: Colors.white54, fontSize: 14)),
                      ),
                    );
                  }
                  return Column(
                    children: withdrawals.map((w) => _withdrawalTile(w)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _withdrawalTile(Map<String, dynamic> w) {
    final status = w['status'] as String? ?? 'pending';
    Color statusColor = status == 'processed' ? Colors.green : status == 'rejected' ? Colors.red : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status == 'processed' ? Icons.check_circle : status == 'rejected' ? Icons.cancel : Icons.hourglass_top,
              color: statusColor, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${(w['inrAmount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${w['tokenAmount']} tokens',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status.toUpperCase(),
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
