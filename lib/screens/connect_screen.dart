// lib/screens/connect_screen.dart

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ConnectScreen extends StatefulWidget {
  final UserModel? currentUser;

  const ConnectScreen({super.key, this.currentUser});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _startRandomCall({required bool isVideo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryPink, AppColors.secondaryPink]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVideo ? Icons.videocam : Icons.phone_in_talk,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Finding someone for a\n${isVideo ? 'video' : 'audio'} call…',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Matching you with an online user',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primaryPink),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryPink),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.primaryPink)),
            ),
          ],
        ),
      ),
    );
  }

  void _callUser(UserModel user, {required bool isVideo}) {
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
                  NetworkImage(AvatarUtils.getAvatarUrl(user.name)),
            ),
            const SizedBox(height: 16),
            Text(
              'Calling ${user.name}…',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Header ─────────────────────────────────────────
              const Text(
                'Connect Now',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 20),

              // ── Random Call Buttons ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _startRandomCall(isVideo: false),
                      child: _buildRandomButton(
                        text: 'Random Audio',
                        icon: Icons.phone_in_talk_outlined,
                        isGradient: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _startRandomCall(isVideo: true),
                      child: _buildRandomButton(
                        text: 'Random Video',
                        icon: Icons.videocam_outlined,
                        isGradient: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Or tap any user below to call them directly',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 24),

              // ── Online Now Header ──────────────────────────────
              StreamBuilder<List<UserModel>>(
                stream: _firestoreService.getOnlineUsers(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Online Now ',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                          children: [
                            TextSpan(
                              text: '($count)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('Live',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── Users Grid ─────────────────────────────────────
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                  stream: _firestoreService.getOnlineUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryPink));
                    }

                    final users = snapshot.data ?? [];

                    if (users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 60,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text(
                              'No one online right now.',
                              style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Be the first to go live!',
                              style: TextStyle(
                                  color: AppColors.textGrey, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(users[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRandomButton({
    required String text,
    required IconData icon,
    required bool isGradient,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isGradient ? null : AppColors.primaryPink.withValues(alpha: 0.1),
        gradient: isGradient
            ? const LinearGradient(
                colors: [AppColors.primaryPink, AppColors.secondaryPink])
            : null,
        borderRadius: BorderRadius.circular(26),
        boxShadow: isGradient
            ? [
                BoxShadow(
                  color: AppColors.primaryPink.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isGradient ? Colors.white : AppColors.primaryPink,
              size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isGradient ? Colors.white : AppColors.primaryPink,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with online dot
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.background,
                backgroundImage:
                    NetworkImage(AvatarUtils.getAvatarUrl(user.name)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            user.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 4),

          // Bio / interests
          Text(
            user.interests.isNotEmpty
                ? user.interests.join(', ')
                : 'Ready to connect',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textGrey, height: 1.3),
          ),
          const SizedBox(height: 8),

          // Interest tags
          if (user.interests.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: user.interests
                  .take(2)
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.primaryPink)),
                      ))
                  .toList(),
            ),

          const Spacer(),

          // Call Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Audio
              GestureDetector(
                onTap: () => _callUser(user, isVideo: false),
                child: Container(
                  width: 40,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.phone_outlined,
                      size: 15, color: AppColors.primaryPink),
                ),
              ),
              const SizedBox(width: 10),
              // Video
              GestureDetector(
                onTap: () => _callUser(user, isVideo: true),
                child: Container(
                  width: 40,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryPink,
                          AppColors.secondaryPink
                        ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.videocam_outlined,
                      size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
