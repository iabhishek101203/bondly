import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

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
              // Header
              const Text(
                'Connect Now',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              
              // Random Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildRandomButton(
                      text: "Random Audio",
                      icon: Icons.phone_in_talk_outlined,
                      color: AppColors.primaryPink.withOpacity(0.1),
                      textColor: AppColors.primaryPink,
                      iconColor: AppColors.primaryPink,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRandomButton(
                      text: "Random Video",
                      icon: Icons.videocam_outlined,
                      color: AppColors.primaryPink,
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      isGradient: true,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Or tap any user below to call them directly",
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Online Now Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: "Online Now ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      children: [
                        TextSpan(
                          text: "(6)",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        )
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
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                       const Text(
                        "Live",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green, // Or similar green
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  )
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Users Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75, // Adjust based on card content
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildUserCard(
                      name: "Sarah Johnson",
                      bio: "Ready to chat about life and motivation",
                      tags: ["Motivation", "Career"],
                    ),
                    _buildUserCard(
                      name: "Michael Chen",
                      bio: "Available for business talks",
                      tags: ["Business", "Technology"],
                    ),
                    _buildUserCard(
                      name: "Emma Davis",
                      bio: "Let's talk about relationships",
                      tags: ["Love & Dating", "Relationships"],
                    ),
                    _buildUserCard(
                      name: "Alex Rivera",
                      bio: "Fitness and wellness coach here!",
                      tags: ["Fitness", "Mental Health"],
                    ),
                  ],
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
    required Color color,
    required Color textColor,
    required Color iconColor,
    bool isGradient = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isGradient ? null : color,
        gradient: isGradient
            ? const LinearGradient(colors: [AppColors.primaryPink, AppColors.secondaryPink])
            : null,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(icon, color: iconColor, size: 20),
           const SizedBox(width: 8),
           Text(
             text,
             style: TextStyle(
               color: textColor,
               fontWeight: FontWeight.bold,
               fontSize: 14,
             ),
           )
         ],
      ),
    );
  }

  Widget _buildUserCard({required String name, required String bio, required List<String> tags}) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
          Stack(
            children: [
               CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.background,
                backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(name)),
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
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bio,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textGrey,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // Tags
           Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 8,
                  color: AppColors.primaryPink,
                ),
              ),
            )).toList(),
          ),
          const Spacer(),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallActionButton(Icons.phone_outlined, false),
              const SizedBox(width: 12),
              _buildSmallActionButton(Icons.videocam_outlined, true),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallActionButton(IconData icon, bool isPrimary) {
    return Container(
      width: 36,
      height: 28, // Pill shape or oval
      decoration: BoxDecoration(
        color: isPrimary ? null : AppColors.primaryPink.withOpacity(0.1),
        gradient: isPrimary
            ? const LinearGradient(colors: [AppColors.primaryPink, AppColors.secondaryPink])
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
       child: Icon(
         icon,
         size: 14,
         color: isPrimary ? Colors.white : AppColors.primaryPink,
       ),
    );
  }
}
