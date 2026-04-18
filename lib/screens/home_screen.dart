import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';
import 'connect_screen.dart';
import 'recents_screen.dart';
import 'profile_screen.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final String _mockUid = 'test-user-123'; // Mock UID for testing user-specific data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or a very light pink/off-white depending on design
      body: SafeArea(
        child: _selectedIndex == 1 
          ? const ConnectScreen()
          : _selectedIndex == 2
              ? const RecentsScreen()
              : _selectedIndex == 3
                  ? ProfileScreen(userName: widget.userName)
                  : StreamBuilder<UserModel?>(
                      stream: _firestoreService.getUserStream(_mockUid),
                      builder: (context, snapshot) {
                        final currentUser = snapshot.data;
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               _buildHeader(currentUser),
                               _buildGreeting(),
                               _buildFavoriteSpeakers(),
                               _buildDailyRewards(currentUser),
                               _buildExploreRooms(),
                               const SizedBox(height: 80), // Space for bottom nav
                            ],
                          ),
                        );
                      }
                    ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      extendBody: true, // For floating effect if needed, but standard is fine
    );
  }

  Widget _buildHeader(UserModel? currentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
                CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.background,
                backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(widget.userName)),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9DB), // Light yellow
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                     const Icon(Icons.monetization_on, color: Colors.orangeAccent, size: 16),
                     const SizedBox(width: 4),
                     Text(
                      "${currentUser?.tokens ?? 0}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               gradient: const LinearGradient(
                 colors: [AppColors.primaryPink, AppColors.secondaryPink],
               ),
               borderRadius: BorderRadius.circular(20),
               boxShadow: [
                 BoxShadow(
                   color: AppColors.primaryPink.withOpacity(0.3),
                   blurRadius: 8,
                   offset: const Offset(0, 4),
                 )
               ],
             ),
             child: const Text(
               "Random Call",
               style: TextStyle(
                 color: Colors.white,
                 fontWeight: FontWeight.w600,
                 fontSize: 12,
               ),
             ),
          )
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Welcome back, ${widget.userName}!",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              const Text("👋", style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Who would you like to connect with today?",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteSpeakers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
               Text(
                "Favorite Speakers",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
               Icon(Icons.favorite, color: AppColors.primaryPink, size: 20),
            ],
          ),
        ),
        StreamBuilder<List<UserModel>>(
          stream: _firestoreService.getFavoriteSpeakers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100, 
                child: Center(child: CircularProgressIndicator())
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Text("No favorite speakers found yet.", style: TextStyle(color: Colors.grey)),
              );
            }
            final speakers = snapshot.data!;
            return SizedBox(
              height: 260, // Increased height to prevent overflow
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24, right: 12),
                itemCount: speakers.length,
                itemBuilder: (context, index) {
                  final speaker = speakers[index];
                  // Convert database "streak/tokens" into mock tags just for UI aesthetics
                  final tags = ["Tokens: ${speaker.tokens}", "Streak: ${speaker.streak}"];
                  return _buildSpeakerCard(
                    name: speaker.name.isNotEmpty ? speaker.name : "Unknown Speaker",
                    tags: tags,
                    rating: 4.8,
                  );
                },
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildSpeakerCard({required String name, required List<String> tags, required double rating}) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // shrink wrap
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.background,
                backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(name)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.star, color: Colors.amber, size: 14),
               const SizedBox(width: 4),
               Text(
                 rating.toString(),
                 style: const TextStyle(
                   fontSize: 12,
                   color: AppColors.textGrey,
                   fontWeight: FontWeight.bold,
                 ),
               ),
            ],
          ),
          const SizedBox(height: 10),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryPink,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          // Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                         Icon(Icons.phone, color: AppColors.primaryPink, size: 14),
                         SizedBox(width: 4),
                         Text("Audio", style: TextStyle(color: AppColors.primaryPink, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryPink, AppColors.secondaryPink]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                         Icon(Icons.videocam, color: Colors.white, size: 14),
                         SizedBox(width: 4),
                         Text("Video", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDailyRewards(UserModel? currentUser) {
    // Determine user claim status safely locally or show baseline
    bool readyToClaim = true;
    if (currentUser != null && currentUser.lastCallDate != null) {
      final now = DateTime.now();
      final last = currentUser.lastCallDate!;
      if (last.year == now.year && last.month == now.month && last.day == now.day) {
        readyToClaim = false;
      }
    }

    final int displayStreak = currentUser?.streak ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daily Rewards",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              if (currentUser != null)
                Text(
                  "🔥 $displayStreak day streak",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                )
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24, right: 12),
            children: [
              // Use Gesture Detectors wrapped around cards to trigger services
              GestureDetector(
                onTap: readyToClaim ? () async {
                  try {
                    await _firestoreService.claimDailyReward(_mockUid);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rewards Claimed!'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  }
                } : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Come back tomorrow to get your next reward!')),
                  );
                },
                child: AbsorbPointer(
                  child: _buildRewardCard(
                    icon: Icons.phone_in_talk, 
                    title: readyToClaim ? "Claim +10 tokens!" : "Claimed today ✅", 
                    reward: "+10",
                    color: readyToClaim ? AppColors.primaryPink : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildRewardCard(
                 icon: Icons.local_fire_department, 
                 title: "3-day streak\nbonus", 
                 reward: "+25",
                 color: (displayStreak >= 3 && displayStreak % 3 == 0) ? Colors.green : Colors.grey.shade400
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard({required IconData icon, required String title, required String reward, required Color color}) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
               Row(
                 children: [
                   const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                   const SizedBox(width: 4),
                   Text(
                     reward,
                     style: const TextStyle(
                       color: Colors.amber,
                       fontWeight: FontWeight.bold,
                       fontSize: 14,
                     ),
                   ),
                 ],
               )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildExploreRooms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Text(
            "Explore Live Rooms",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        StreamBuilder<List<RoomModel>>(
          stream: _firestoreService.getLiveRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text("No live rooms at the moment."),
              );
            }
            
            final rooms = snapshot.data!;
            // For now, mapping rooms to a horizontal row of colorful boxes
            // Similar to the static design but dynamic length.
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  // Toggle colors for aesthetics
                  final boxColor = index % 2 == 0 ? const Color(0xFFEA5B7D) : const Color(0xFF9D5BFF);
                  final icon = index % 2 == 0 ? Icons.phone_callback : Icons.gamepad;
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                       color: boxColor,
                       borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                            Icon(icon, size: 40, color: Colors.white),
                            const SizedBox(height: 12),
                            Text(
                              room.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${room.participants} listening",
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                            ),
                         ],
                       )
                    ),
                  );
                },
              ),
            );
          }
        )

      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.people_outline, "Connect", 1),
                _buildNavItem(Icons.access_time, "Recents", 2),
                _buildNavItem(Icons.person_outline, "Profile", 3),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(
               icon, 
               color: isSelected ? AppColors.primaryPink : AppColors.textGrey,
               size: 24,
             ),
             const SizedBox(height: 4),
             Text(
               label,
               style: TextStyle(
                 color: isSelected ? AppColors.primaryPink : AppColors.textGrey,
                 fontSize: 10,
                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
               ),
             )
          ],
        ),
      );
  }

}
