import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';
import 'connect_screen.dart';
import 'recents_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           _buildHeader(),
                           _buildGreeting(),
                           _buildFavoriteSpeakers(),
                           _buildDailyRewards(),
                           _buildExploreRooms(),
                           const SizedBox(height: 80), // Space for bottom nav
                        ],
                      ),
                    ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      extendBody: true, // For floating effect if needed, but standard is fine
    );
  }

  Widget _buildHeader() {
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
                  children: const [
                     Icon(Icons.monetization_on, color: Colors.orangeAccent, size: 16),
                     SizedBox(width: 4),
                     Text(
                      "100",
                      style: TextStyle(
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
        SizedBox(
          height: 260, // Increased height to prevent overflow
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24, right: 12),
            children: [
              _buildSpeakerCard(
                name: "Sarah Johnson",
                tags: ["Motivation", "Career"],
                rating: 4.8,
              ),
              _buildSpeakerCard(
                name: "David Chen",
                tags: ["Business", "Finance"],
                rating: 4.9,
              ),
            ],
          ),
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

  Widget _buildDailyRewards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Text(
            "Daily Rewards",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24, right: 12),
            children: [
              _buildRewardCard(
                icon: Icons.phone_in_talk, 
                title: "First call of the day", 
                reward: "+10",
                color: AppColors.primaryPink
              ),
              const SizedBox(width: 16),
              _buildRewardCard(
                icon: Icons.local_fire_department, 
                title: "3-day streak\nbonus", 
                reward: "+25",
                color: Colors.green
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
            "Explore Rooms",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 140,
                   decoration: BoxDecoration(
                     color: const Color(0xFFEA5B7D), // Darker pink
                     borderRadius: BorderRadius.circular(24),
                   ),
                   child: const Center(
                     child: Icon(Icons.phone_callback, size: 40, color: Colors.white),
                   ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 140,
                   decoration: BoxDecoration(
                     color: const Color(0xFF9D5BFF), // Purple
                     borderRadius: BorderRadius.circular(24),
                   ),
                   child: const Center(
                     child: Icon(Icons.gamepad, size: 40, color: Colors.white),
                   ),
                ),
              ),
            ],
          ),
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
