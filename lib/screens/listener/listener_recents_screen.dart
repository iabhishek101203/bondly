// lib/screens/listener/listener_recents_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/avatar_utils.dart';
import '../../models/user_model.dart';
import '../../models/call_model.dart';
import '../../services/firestore_service.dart';
import '../call_screen.dart';

class ListenerRecentsScreen extends StatelessWidget {
  final UserModel currentUser;
  const ListenerRecentsScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Recent Calls', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Your call history', style: TextStyle(color: Colors.white54, fontSize: 14)),
            ),
            const SizedBox(height: 16),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _statCard('${currentUser.totalCalls}', 'Calls'),
                  const SizedBox(width: 12),
                  _statCard('${currentUser.totalMinutes}', 'Minutes'),
                  const SizedBox(width: 12),
                  _statCard('${currentUser.favoriteUids.length}', 'Favorites'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<CallModel>>(
                stream: fs.getCallHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                  }
                  final calls = snapshot.data ?? [];
                  if (calls.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📞', style: TextStyle(fontSize: 56)),
                          SizedBox(height: 16),
                          Text('No calls yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('Start connecting with speakers!', style: TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: calls.length,
                    itemBuilder: (context, i) => _callTile(context, calls[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryPink.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(count, style: const TextStyle(color: AppColors.primaryPink, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _callTile(BuildContext context, CallModel call) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(call.otherUserName)),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: call.isMissed ? Colors.red : AppColors.primaryPink,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F0F1A), width: 2),
                  ),
                  child: Icon(
                    call.isMissed ? Icons.call_missed : call.isVideo ? Icons.videocam : Icons.phone,
                    color: Colors.white, size: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(call.otherUserName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white38, size: 11),
                    const SizedBox(width: 3),
                    Text(call.timeAgo, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Text('·', style: TextStyle(color: Colors.white38)),
                    const SizedBox(width: 8),
                    Text(call.durationLabel,
                        style: TextStyle(
                          color: call.isMissed ? Colors.red : Colors.white54,
                          fontSize: 11,
                          fontWeight: call.isMissed ? FontWeight.bold : FontWeight.normal,
                        )),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CallScreen(
                otherUser: UserModel(uid: call.otherUserUid, name: call.otherUserName),
                isVideo: call.isVideo,
                isOutgoing: true,
              ),
            )),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: call.isVideo ? AppColors.primaryPink : Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(call.isVideo ? Icons.videocam : Icons.phone,
                  color: call.isVideo ? Colors.white : AppColors.primaryPink, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
