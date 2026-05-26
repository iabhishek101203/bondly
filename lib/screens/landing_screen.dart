// lib/screens/landing_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'create_account_screen.dart';
import 'user_registration_screen.dart';
import 'home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null && mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Logo
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE94057), Color(0xFFF27121)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(
                          color: AppColors.primaryPink.withValues(alpha: 0.3),
                          blurRadius: 20, offset: const Offset(0, 10),
                        )],
                      ),
                      child: const Icon(Icons.favorite, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 28),
                    const Text('Bondly',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    const Text('Real connections through voice and video',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: AppColors.textGrey)),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _featureIcon(Icons.call_outlined, 'Voice Calls'),
                        _featureIcon(Icons.videocam_outlined, 'Video Calls'),
                        _featureIcon(Icons.card_giftcard_outlined, 'Send Gifts'),
                        _featureIcon(Icons.groups_outlined, 'Go Live'),
                      ],
                    ),
                    const Spacer(),
                    CustomButton(
                      text: 'Get Started',
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CreateAccountScreen())),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Sign In',
                      isOutline: true,
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SignInScreen())),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _featureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, color: AppColors.primaryPink, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
