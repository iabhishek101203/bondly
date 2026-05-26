// lib/screens/interests_screen.dart

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';

class InterestsScreen extends StatefulWidget {
  final String userName;
  const InterestsScreen({super.key, required this.userName});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final FirestoreService _fs = FirestoreService();
  final List<String> _interests = [
    'Motivation', 'Love & Dating', 'Mental Health', 'Career',
    'Relationships', 'Fitness', 'Spirituality', 'Business',
    'Art & Creativity', 'Technology', 'Music', 'Travel',
    'Cooking', 'Finance', 'Fashion', 'Gaming',
  ];
  final Set<String> _selected = {};
  final int _max = 5;
  bool _isLoading = false;

  void _toggle(String interest) {
    setState(() {
      if (_selected.contains(interest)) {
        _selected.remove(interest);
      } else if (_selected.length < _max) {
        _selected.add(interest);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Max 5 interests'), backgroundColor: Colors.orange),
        );
      }
    });
  }

  Future<void> _proceed() async {
    setState(() => _isLoading = true);
    try {
      if (_selected.isNotEmpty) {
        await _fs.updateProfile(interests: _selected.toList());
      }
    } catch (_) {}
    finally { if (mounted) setState(() => _isLoading = false); }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryPink, AppColors.secondaryPink]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primaryPink.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),
              const Text('What interests you?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              const Text('Select up to 5 topics for better matches',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${_selected.length}/$_max selected',
                      style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                  if (_selected.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle, color: AppColors.primaryPink, size: 16),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 10, runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _interests.map((interest) {
                      final sel = _selected.contains(interest);
                      return GestureDetector(
                        onTap: () => _toggle(interest),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primaryPink.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: sel ? AppColors.primaryPink : Colors.grey.shade200,
                              width: sel ? 2 : 1,
                            ),
                            boxShadow: sel ? [BoxShadow(
                              color: AppColors.primaryPink.withValues(alpha: 0.15),
                              blurRadius: 8, offset: const Offset(0, 4),
                            )] : [],
                          ),
                          child: Text(interest,
                              style: TextStyle(
                                color: sel ? AppColors.primaryPink : AppColors.textDark,
                                fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primaryPink)
                  : CustomButton(
                      text: _selected.isEmpty ? 'Select at least one' : 'Start Exploring 🚀',
                      onPressed: _selected.isEmpty ? null : _proceed,
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _isLoading ? null : _proceed,
                child: const Text('Skip for now', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
