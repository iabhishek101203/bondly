// lib/screens/listener/listener_connect_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/avatar_utils.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../call_screen.dart';
import '../chat_screen.dart';

class ListenerConnectScreen extends StatelessWidget {
  final UserModel currentUser;
  const ListenerConnectScreen({super.key, required this.currentUser});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connect', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Talk one-on-one with speakers', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Random call buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _randomCallBtn(context, isVideo: false)),
                  const SizedBox(width: 12),
                  Expanded(child: _randomCallBtn(context, isVideo: true)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Online Speakers', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: fs.getOnlineSpeakers(preference: currentUser.preference),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                  }
                  final speakers = snapshot.data ?? [];
                  if (speakers.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('😴', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('No speakers online right now', style: TextStyle(color: Colors.white54, fontSize: 15)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: speakers.length,
                    itemBuilder: (context, i) => _speakerTile(context, speakers[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _randomCallBtn(BuildContext context, {required bool isVideo}) {
    return GestureDetector(
      onTap: () => _showMatchingDialog(context, isVideo: isVideo),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: isVideo
              ? const LinearGradient(colors: [AppColors.primaryPink, AppColors.secondaryPink])
              : null,
          color: isVideo ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(26),
          border: isVideo ? null : Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isVideo ? Icons.videocam : Icons.phone_in_talk,
                color: isVideo ? Colors.white : Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(isVideo ? 'Random Video' : 'Random Audio',
                style: TextStyle(
                  color: isVideo ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold, fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }

  void _showMatchingDialog(BuildContext context, {required bool isVideo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryPink, AppColors.secondaryPink]),
                shape: BoxShape.circle,
              ),
              child: Icon(isVideo ? Icons.videocam : Icons.phone_in_talk, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Finding someone for a\n${isVideo ? 'video' : 'audio'} call…',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primaryPink),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _speakerTile(BuildContext context, UserModel speaker) {
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
                radius: 26,
                backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(speaker.name)),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: speaker.isLive ? Colors.red : Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F0F1A), width: 2),
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
                Text(speaker.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  speaker.isLive ? '🔴 Live now' : '🟢 Online',
                  style: TextStyle(
                    color: speaker.isLive ? Colors.red : Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
                if (speaker.interests.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(speaker.interests.take(2).join(' · '),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          // Call buttons
          Row(
            children: [
              _actionBtn(
                icon: '💬',
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChatScreen(otherUser: speaker),
                )),
              ),
              const SizedBox(width: 8),
              _actionBtn(
                icon: '📞',
                isPrimary: false,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CallScreen(otherUser: speaker, isVideo: false, isOutgoing: true),
                )),
              ),
              const SizedBox(width: 8),
              _actionBtn(
                icon: '📹',
                isPrimary: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CallScreen(otherUser: speaker, isVideo: true, isOutgoing: true),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({required String icon, bool isPrimary = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryPink : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
      ),
    );
  }
}
