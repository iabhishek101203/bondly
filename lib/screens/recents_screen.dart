// lib/screens/recents_screen.dart

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';
import '../models/user_model.dart';
import '../models/call_model.dart';
import '../services/firestore_service.dart';

class RecentsScreen extends StatefulWidget {
  final UserModel? currentUser;

  const RecentsScreen({super.key, this.currentUser});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _callBack(CallModel call, {required bool isVideo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage:
                  NetworkImage(AvatarUtils.getAvatarUrl(call.otherUserName)),
            ),
            const SizedBox(height: 16),
            Text(
              'Calling ${call.otherUserName}…',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              isVideo ? '📹 Video Call' : '📞 Audio Call',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primaryPink),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCalls = widget.currentUser?.totalCalls ?? 0;
    final totalMins = widget.currentUser?.totalMinutes ?? 0;
    final favCount = widget.currentUser?.favoriteUids.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Calls',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your call history and favorites',
                    style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 20),

                  // ── Stats Row ─────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              count: '$totalCalls', label: 'Total Calls')),
                      const SizedBox(width: 12),
                      Expanded(
                          child:
                              _StatCard(count: '$favCount', label: 'Favorites')),
                      const SizedBox(width: 12),
                      Expanded(
                          child:
                              _StatCard(count: '$totalMins', label: 'Total Mins')),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Call History List ─────────────────────────────────
            Expanded(
              child: StreamBuilder<List<CallModel>>(
                stream: _firestoreService.getCallHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryPink));
                  }

                  final calls = snapshot.data ?? [];

                  if (calls.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_outlined,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'No calls yet.',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGrey),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Start connecting with people!',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: calls.length,
                    itemBuilder: (context, index) {
                      return _buildRecentCard(calls[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(CallModel call) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Avatar with call type indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.background,
                backgroundImage: NetworkImage(
                    AvatarUtils.getAvatarUrl(call.otherUserName)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: call.isMissed
                        ? Colors.redAccent
                        : AppColors.primaryPink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    call.isMissed
                        ? Icons.call_missed
                        : call.isVideo
                            ? Icons.videocam
                            : Icons.phone,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Name + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.otherUserName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(call.timeAgo,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(width: 8),
                    const Text('•',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(width: 8),
                    Text(
                      call.durationLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            call.isMissed ? Colors.redAccent : AppColors.textGrey,
                        fontWeight: call.isMissed
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Call back button
          GestureDetector(
            onTap: () => _callBack(call, isVideo: call.isVideo),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: call.isVideo
                    ? AppColors.primaryPink
                    : AppColors.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                call.isVideo ? Icons.videocam : Icons.phone,
                color: call.isVideo ? Colors.white : AppColors.primaryPink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String count;
  final String label;

  const _StatCard({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.pink.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPink),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
