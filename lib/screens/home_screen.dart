// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';
import 'connect_screen.dart';
import 'recents_screen.dart';
import 'profile_screen.dart';
import 'add_tokens.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Mark user as online when app opens
    _firestoreService.setOnlineStatus(true);
  }

  @override
  void dispose() {
    _firestoreService.setOnlineStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _firestoreService.getCurrentUserStream(),
      builder: (context, snapshot) {
        final currentUser = snapshot.data;
        final userName = currentUser?.name ??
            FirebaseAuth.instance.currentUser?.displayName ??
            'User';

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                // ── Home Tab ──────────────────────────────────────
                _buildHomeTab(currentUser, userName),
                // ── Connect Tab ───────────────────────────────────
                ConnectScreen(currentUser: currentUser),
                // ── Recents Tab ───────────────────────────────────
                RecentsScreen(currentUser: currentUser),
                // ── Profile Tab ───────────────────────────────────
                ProfileScreen(
                  currentUser: currentUser,
                  userName: userName,
                  onAddTokens: () => _openAddTokens(currentUser, userName),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
          extendBody: true,
        );
      },
    );
  }

  // ── Home Tab ──────────────────────────────────────────────────────

  Widget _buildHomeTab(UserModel? currentUser, String userName) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(currentUser, userName),
          _buildGreeting(userName),
          _buildFavoriteSpeakers(),
          _buildDailyRewards(currentUser),
          _buildExploreRooms(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────

  Widget _buildHeader(UserModel? currentUser, String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 3),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.background,
                  backgroundImage:
                      NetworkImage(AvatarUtils.getAvatarUrl(userName)),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _openAddTokens(currentUser, userName),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9DB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${currentUser?.tokens ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _onRandomCallTapped,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPink, AppColors.secondaryPink],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Random Call',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onRandomCallTapped() {
    // Switch to Connect tab and trigger random matching
    setState(() => _selectedIndex = 1);
    // A short delay so the tab switches before showing the dialog
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _showRandomCallDialog();
    });
  }

  void _showRandomCallDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Start a Random Call',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect with someone new instantly',
              style: TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _callTypeButton(
                    icon: Icons.phone_in_talk,
                    label: 'Audio Call',
                    isGradient: false,
                    onTap: () {
                      Navigator.pop(context);
                      _startRandomCall(isVideo: false);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _callTypeButton(
                    icon: Icons.videocam,
                    label: 'Video Call',
                    isGradient: true,
                    onTap: () {
                      Navigator.pop(context);
                      _startRandomCall(isVideo: true);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _callTypeButton({
    required IconData icon,
    required String label,
    required bool isGradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isGradient
              ? const LinearGradient(
                  colors: [AppColors.primaryPink, AppColors.secondaryPink])
              : null,
          color: isGradient ? null : AppColors.primaryPink.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isGradient ? Colors.white : AppColors.primaryPink,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isGradient ? Colors.white : AppColors.primaryPink,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRandomCall({required bool isVideo}) {
    // Show a matching spinner — in production this would connect to a signaling server
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.primaryPink),
            const SizedBox(height: 20),
            Text(
              'Finding someone for a\n${isVideo ? 'video' : 'audio'} call...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.primaryPink)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Greeting ──────────────────────────────────────────────────────

  Widget _buildGreeting(String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Welcome back, $userName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('👋', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Who would you like to connect with today?',
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  // ── Favorite Speakers ─────────────────────────────────────────────

  Widget _buildFavoriteSpeakers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Favorite Speakers',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: const Icon(Icons.favorite,
                    color: AppColors.primaryPink, size: 20),
              ),
            ],
          ),
        ),
        StreamBuilder<List<UserModel>>(
          stream: _firestoreService.getFavoriteSpeakers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryPink)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.people_outline, color: AppColors.primaryPink),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No featured speakers yet.\nCheck the Connect tab to meet people!',
                          style:
                              TextStyle(color: AppColors.textGrey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 24, right: 12),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final speaker = snapshot.data![index];
                  return _buildSpeakerCard(speaker: speaker);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpeakerCard({required UserModel speaker}) {
    return GestureDetector(
      onTap: () => _showUserProfile(speaker),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16, bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.background,
                  backgroundImage: NetworkImage(
                      AvatarUtils.getAvatarUrl(speaker.name)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: speaker.isOnline
                          ? Colors.greenAccent
                          : Colors.grey.shade300,
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              speaker.name.isNotEmpty ? speaker.name : 'Speaker',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textDark),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  speaker.rating > 0
                      ? speaker.rating.toStringAsFixed(1)
                      : 'New',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (speaker.interests.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: speaker.interests
                    .take(2)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(tag,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primaryPink)),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _initiateCall(
                        speaker, isVideo: false),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone,
                              color: AppColors.primaryPink, size: 14),
                          SizedBox(width: 4),
                          Text('Audio',
                              style: TextStyle(
                                  color: AppColors.primaryPink,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _initiateCall(speaker, isVideo: true),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryPink,
                              AppColors.secondaryPink
                            ]),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Video',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Daily Rewards ─────────────────────────────────────────────────

  Widget _buildDailyRewards(UserModel? currentUser) {
    bool readyToClaim = true;
    if (currentUser?.lastCallDate != null) {
      final now = DateTime.now();
      final last = currentUser!.lastCallDate!;
      if (last.year == now.year &&
          last.month == now.month &&
          last.day == now.day) {
        readyToClaim = false;
      }
    }
    final int streak = currentUser?.streak ?? 0;
    final bool streakBonus = streak > 0 && streak % 3 == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Rewards',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🔥 $streak day streak',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 24, right: 12),
            children: [
              GestureDetector(
                onTap: () => _claimDailyReward(readyToClaim),
                child: _buildRewardCard(
                  icon: Icons.phone_in_talk,
                  title: readyToClaim ? 'Claim +10 tokens!' : 'Claimed today ✅',
                  reward: '+10',
                  color: readyToClaim ? AppColors.primaryPink : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: streakBonus
                    ? () => _claimDailyReward(readyToClaim)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(streak == 0
                                ? 'Start your streak to earn this bonus!'
                                : 'Keep going! ${3 - (streak % 3)} more day(s) for +25 bonus'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                child: _buildRewardCard(
                  icon: Icons.local_fire_department,
                  title: '3-day streak\nbonus',
                  reward: '+25',
                  color: streakBonus ? Colors.green : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _claimDailyReward(bool readyToClaim) async {
    if (!readyToClaim) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Come back tomorrow for your next reward! 🌅'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      await _firestoreService.claimDailyReward();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Tokens claimed! Great work!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildRewardCard({
    required IconData icon,
    required String title,
    required String reward,
    required Color color,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.monetization_on,
                      size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(reward,
                      style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Live Rooms ────────────────────────────────────────────────────

  Widget _buildExploreRooms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Text(
            'Explore Live Rooms',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
        ),
        StreamBuilder<List<RoomModel>>(
          stream: _firestoreService.getLiveRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryPink)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.meeting_room_outlined,
                          color: Colors.deepPurple),
                      SizedBox(width: 12),
                      Text(
                        'No live rooms right now.\nCheck back soon!',
                        style:
                            TextStyle(color: AppColors.textGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }
            final rooms = snapshot.data!;
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final colors = [
                    const Color(0xFFEA5B7D),
                    const Color(0xFF9D5BFF),
                    const Color(0xFF5B8EFF),
                  ];
                  final icons = [
                    Icons.phone_callback,
                    Icons.gamepad,
                    Icons.music_note
                  ];
                  final c = colors[index % colors.length];
                  final ic = icons[index % icons.length];
                  return GestureDetector(
                    onTap: () => _joinRoom(room),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(ic, size: 36, color: Colors.white),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                room.title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                            Text(
                              '${room.participants} listening',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.people_outline, 'Connect', 1),
              _buildNavItem(Icons.access_time, 'Recents', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPink.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryPink
                  : AppColors.textGrey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryPink
                    : AppColors.textGrey,
                fontSize: 10,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  void _openAddTokens(UserModel? user, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTokenScreen(
          currentBalance: user?.tokens ?? 0,
          userName: name,
        ),
      ),
    );
  }

  void _initiateCall(UserModel target, {required bool isVideo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage:
                  NetworkImage(AvatarUtils.getAvatarUrl(target.name)),
            ),
            const SizedBox(height: 16),
            Text(
              'Calling ${target.name}…',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              isVideo ? '📹 Video Call' : '📞 Audio Call',
              style: const TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
                color: AppColors.primaryPink),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfile(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _UserProfileSheet(
        user: user,
        firestoreService: _firestoreService,
        onCall: (isVideo) {
          Navigator.pop(context);
          _initiateCall(user, isVideo: isVideo);
        },
      ),
    );
  }

  void _joinRoom(RoomModel room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining "${room.title}"…'),
        backgroundColor: AppColors.primaryPink,
      ),
    );
  }
}

// ── User Profile Bottom Sheet ─────────────────────────────────────────

class _UserProfileSheet extends StatefulWidget {
  final UserModel user;
  final FirestoreService firestoreService;
  final void Function(bool isVideo) onCall;

  const _UserProfileSheet({
    required this.user,
    required this.firestoreService,
    required this.onCall,
  });

  @override
  State<_UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<_UserProfileSheet> {
  bool _isFav = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.firestoreService.isFavorite(widget.user.uid).then((v) {
      if (mounted) setState(() { _isFav = v; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 44,
            backgroundImage:
                NetworkImage(AvatarUtils.getAvatarUrl(widget.user.name)),
          ),
          const SizedBox(height: 12),
          Text(
            widget.user.name,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
          if (widget.user.interests.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: widget.user.interests
                  .take(3)
                  .map((i) => Chip(
                        label: Text(i,
                            style:
                                const TextStyle(fontSize: 11, color: AppColors.primaryPink)),
                        backgroundColor:
                            AppColors.primaryPink.withValues(alpha: 0.08),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onCall(false),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: AppColors.primaryPink, size: 18),
                        SizedBox(width: 8),
                        Text('Audio Call',
                            style: TextStyle(
                                color: AppColors.primaryPink,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onCall(true),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.primaryPink, AppColors.secondaryPink]),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Video Call',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _loading
                    ? null
                    : () async {
                        await widget.firestoreService
                            .toggleFavorite(widget.user.uid);
                        if (mounted) setState(() => _isFav = !_isFav);
                      },
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: _isFav
                        ? AppColors.primaryPink.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFav ? Icons.favorite : Icons.favorite_border,
                    color: _isFav ? AppColors.primaryPink : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
