// lib/screens/listener/listener_home.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/avatar_utils.dart';
import '../../models/user_model.dart';
import '../../models/room_model.dart';
import '../../services/firestore_service.dart';
import '../../screens/add_tokens.dart';
import '../listener/live_room_screen.dart';
import '../listener/listener_connect_screen.dart';
import '../listener/listener_recents_screen.dart';
import '../listener/listener_profile_screen.dart';

class ListenerHome extends StatefulWidget {
  final UserModel currentUser;
  const ListenerHome({super.key, required this.currentUser});

  @override
  State<ListenerHome> createState() => _ListenerHomeState();
}

class _ListenerHomeState extends State<ListenerHome> {
  int _selectedIndex = 0;
  String _selectedCategory = 'all';
  final FirestoreService _fs = FirestoreService();

  final List<Map<String, String>> _categories = [
    {'id': 'all',     'label': 'All',     'emoji': '✨'},
    {'id': 'chat',    'label': 'Chat',    'emoji': '💬'},
    {'id': 'fun',     'label': 'Fun',     'emoji': '😂'},
    {'id': 'singing', 'label': 'Singing', 'emoji': '🎵'},
    {'id': 'games',   'label': 'Games',   'emoji': '🎮'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          ListenerConnectScreen(currentUser: widget.currentUser),
          ListenerRecentsScreen(currentUser: widget.currentUser),
          ListenerProfileScreen(currentUser: widget.currentUser),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildLiveFeed()),
        ],
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(widget.currentUser.name)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi, ${widget.currentUser.name.split(' ').first}! 👋',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const Text('Discover live speakers',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          // Token balance
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AddTokenScreen(
                  currentBalance: widget.currentUser.tokens,
                  userName: widget.currentUser.name,
                ))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFAB00).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFAB00).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text('${widget.currentUser.tokens}',
                      style: const TextStyle(
                          color: Color(0xFFFFAB00), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.add, color: Color(0xFFFFAB00), size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Filter ────────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = _selectedCategory == cat['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryPink : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(cat['emoji']!, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(cat['label']!,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Live Feed ──────────────────────────────────────────────────────
  Widget _buildLiveFeed() {
    final category = _selectedCategory == 'all' ? null : _selectedCategory;
    return StreamBuilder<List<RoomModel>>(
      stream: _fs.getLiveRooms(category: category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
        }

        final rooms = snapshot.data ?? [];

        if (rooms.isEmpty) {
          return _buildEmptyFeed();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.72,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, i) => _buildRoomCard(rooms[i]),
        );
      },
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    final colors = [
      [const Color(0xFFE94057), const Color(0xFFFF6B8A)],
      [const Color(0xFF7E57C2), const Color(0xFFB39DDB)],
      [const Color(0xFF00897B), const Color(0xFF4DB6AC)],
      [const Color(0xFFE65100), const Color(0xFFFF8A65)],
      [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
    ];
    final colorPair = colors[room.id.hashCode % colors.length];

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => LiveRoomScreen(room: room, currentUser: widget.currentUser),
      )),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colorPair,
          ),
        ),
        child: Stack(
          children: [
            // Background avatar area
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(room.speakerName)),
                  ),
                ),
              ),
            ),

            // LIVE badge
            Positioned(
              top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 6),
                    SizedBox(width: 4),
                    Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // Viewer count
            Positioned(
              top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.remove_red_eye, color: Colors.white, size: 10),
                    const SizedBox(width: 3),
                    Text('${room.participants}',
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
            ),

            // Bottom info
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.speakerName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${room.categoryEmoji} ${room.title}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    // Join button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: const Center(
                        child: Text('Join Room',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😴', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('No one is live right now',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Check back soon!',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 24),
          // Show online speakers even if not live
          StreamBuilder<List<UserModel>>(
            stream: _fs.getOnlineSpeakers(preference: widget.currentUser.preference),
            builder: (context, snap) {
              final speakers = snap.data ?? [];
              if (speakers.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  const Text('Online Speakers',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: speakers.length,
                      itemBuilder: (context, i) => _buildOnlineSpeakerAvatar(speakers[i]),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineSpeakerAvatar(UserModel speaker) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
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
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F0F1A), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(speaker.name.split(' ').first,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,     'label': 'Home'},
      {'icon': Icons.people_outline,   'label': 'Connect'},
      {'icon': Icons.access_time,      'label': 'Recents'},
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
