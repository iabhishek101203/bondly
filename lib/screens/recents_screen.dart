import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';

class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                const Text(
                  'Recent Calls',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your call history and favorites',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 24),

                // Recent List
                _buildRecentCard(
                  name: "Sarah Johnson",
                  time: "1h ago",
                  duration: "15 mins",
                  isFavorite: true,
                  isVideo: true,
                  isMissed: false,
                ),
                _buildRecentCard(
                  name: "Michael Chen",
                  time: "3h ago",
                  duration: "8 mins",
                  isFavorite: false,
                  isVideo: false,
                  isMissed: false,
                ),
                 _buildRecentCard(
                  name: "Emma Davis",
                  time: "Yesterday",
                  duration: "22 mins",
                  isFavorite: true,
                  isVideo: true,
                  isMissed: false,
                ),
                _buildRecentCard(
                  name: "Alex Rivera",
                  time: "2d ago",
                  duration: "Missed",
                  isFavorite: false,
                  isVideo: false, // Icon shows phone for missed in screenshot example (or generic)
                  isMissed: true,
                ),

                const SizedBox(height: 30),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _StatItem(count: "4", label: "Total Calls"),
                    _StatItem(count: "2", label: "Favorites"),
                    _StatItem(count: "45", label: "Total Mins"),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCard({
    required String name,
    required String time,
    required String duration,
    required bool isFavorite,
    required bool isVideo,
    required bool isMissed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Stack(
            children: [
               CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.background,
                backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(name)),
              ),
              if (isVideo) // Just using video flag to show an indicator style if needed, 
                          // but screenshot shows small icon on avatar sometimes? 
                          // Actually screenshot has icon ON avatar for some. 
                          // Let's stick to the simpler avatar + status indicator.
              Positioned(
                 bottom: 0,
                 right: 0,
                 child: Container(
                   padding: const EdgeInsets.all(4),
                   decoration: BoxDecoration(
                     color: AppColors.primaryPink,
                     shape: BoxShape.circle,
                     border: Border.all(color: Colors.white, width: 2),
                   ),
                   child: Icon(
                     isVideo ? Icons.videocam : Icons.phone,
                     color: Colors.white,
                     size: 10,
                   ),
                 ),
               )
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (isFavorite) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.favorite, color: AppColors.primaryPink, size: 14),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(width: 8),
                    const Text("•", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(width: 8),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12, 
                        color: isMissed ? Colors.redAccent : AppColors.textGrey,
                        fontWeight: isMissed ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
               Icon(
                 isFavorite ? Icons.favorite : Icons.favorite_border,
                 color: isFavorite ? AppColors.primaryPink.withOpacity(0.5) : Colors.grey.shade300, 
                 // Screenshot shows light pink heart background sometimes? 
                 // It shows a separate button actually.
                 size: 20,
               ),
               const SizedBox(width: 12),
               Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(
                   color: isVideo ? AppColors.primaryPink : AppColors.primaryPink.withOpacity(0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   isVideo ? Icons.videocam : Icons.phone,
                   color: isVideo ? Colors.white : AppColors.primaryPink,
                   size: 20,
                 ),
               )
            ],
          )
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.pink.shade50.withOpacity(0.3), // Very light pink
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
