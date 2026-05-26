// lib/screens/create_account_screen.dart

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(children: [
                  Icon(Icons.arrow_back, size: 20, color: AppColors.textGrey),
                  SizedBox(width: 4),
                  Text('Back', style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
                ]),
              ),
              const SizedBox(height: 30),
              const Text('Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              const Text('Choose your role to get started',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
              const SizedBox(height: 40),
              RoleSelectionCard(
                icon: Icons.phone_in_talk_outlined,
                title: "I'm a Speaker 🎙️",
                description: 'Go live, connect with people & earn tokens by sharing your time',
                iconGradient: const [Color(0xFF7E57C2), Color(0xFFE94057)],
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const UserRegistrationScreen(role: 'speaker'),
                )),
              ),
              const SizedBox(height: 20),
              RoleSelectionCard(
                icon: Icons.headphones_outlined,
                title: "I'm a Listener 🎧",
                description: 'Discover live speakers, send gifts & enjoy one-on-one conversations',
                iconGradient: const [Color(0xFFE94057), Color(0xFFF27121)],
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const UserRegistrationScreen(role: 'listener'),
                )),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
