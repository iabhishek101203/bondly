import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/role_selection_card.dart';
import 'user_registration_screen.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

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
                const SizedBox(height: 10),
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, size: 20, color: AppColors.textGrey),
                      SizedBox(width: 4),
                      Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Header
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose your role to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 40),

                // Role Cards
                RoleSelectionCard(
                  icon: Icons.phone_in_talk_outlined,
                  title: "I'm a Speaker",
                  description: "Share your time and earn tokens by connecting with others",
                  iconGradient: const [Color(0xFFE94057), Color(0xFFF27121)],
                  onTap: () {
                    // TODO: Handle Speaker selection
                  },
                ),
                const SizedBox(height: 20),
                RoleSelectionCard(
                  icon: Icons.favorite,
                  title: "I'm Looking to Connect",
                  description: "Discover and connect with amazing speakers",
                  iconGradient: const [Color(0xFFD96FF8), Color(0xFFE94057)],
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserRegistrationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
