// lib/screens/home_screen.dart
// Routes to ListenerHome or SpeakerDashboard based on user role

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'listener/listener_home.dart';
import 'speaker/speaker_dashboard.dart';
import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
          );
        }

        // Route based on role
        if (user.isSpeaker) {
          return SpeakerDashboard(currentUser: user);
        } else {
          return ListenerHome(currentUser: user);
        }
      },
    );
  }
}
