import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class InterestsScreen extends StatefulWidget {
  final String userName;

  const InterestsScreen({super.key, required this.userName});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<String> _interests = [
    "Motivation",
    "Love & Dating",
    "Mental Health",
    "Career",
    "Relationships",
    "Fitness",
    "Spirituality",
    "Business",
    "Art & Creativity",
    "Technology",
    "Music",
    "Travel",
    "Cooking",
    "Finance",
    "Fashion"
  ];

  final Set<String> _selectedInterests = {};
  final int _maxSelection = 5;

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length < _maxSelection) {
          _selectedInterests.add(interest);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can only select up to 5 interests")),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Pale red background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Sparkle Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPink, AppColors.secondaryPink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'What interests you?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              const Text(
                'Select topics to help us find the perfect\nspeakers for you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              // Counter
              Text(
                'Selected: ${_selectedInterests.length}/$_maxSelection',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 20),
              
              // Interests Honeycomb/Grid
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _interests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return GestureDetector(
                        onTap: () => _toggleInterest(interest),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryPink : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primaryPink.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                            ],
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryPink : AppColors.textDark,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Start Exploring Button
              CustomButton(
                text: _selectedInterests.isEmpty ? "Select at least one interest" : "Start Exploring",
                // Disable button if no selection? Or change text? 
                // Screenshot says "Select at least one interest" on the button, which likely means it's disabled or prompts
                // But the user wants "Start exploring" to go to home.
                // I'll make it actionable only if at least 1 is selected.
                onPressed: () {
                   if (_selectedInterests.isNotEmpty) {
                     Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(userName: widget.userName),
                      ),
                      (route) => false,
                    );
                   }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Skip
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(userName: widget.userName),
                      ),
                      (route) => false,
                    );
                },
                child: const Text(
                  "Skip for now",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
