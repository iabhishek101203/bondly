import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'create_account_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       const Spacer(),
                      // Logo Section
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: -30,
                            top: -20,
                            child: Icon(
                              Icons.favorite,
                              size: 80,
                              color: AppColors.primaryPink.withOpacity(0.1),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE94057), Color(0xFFF27121)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPink.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Title
                      const Text(
                        'Bondly',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Real connections through voice and video',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Feature Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureIcon(Icons.call_outlined, "Voice Calls"),
                          _buildFeatureIcon(Icons.videocam_outlined, "Video Calls"),
                          _buildFeatureIcon(Icons.groups_outlined, "Group Rooms"),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Buttons
                      CustomButton(
                        text: "Get Started",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateAccountScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: "Sign In",
                        isOutline: true,
                        onPressed: () {
                           // TODO: Navigate to Sign In
                        },
                      ),
                      
                      const SizedBox(height: 30),
                     
                      // Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
                            children: [
                              const TextSpan(text: "By continuing, you agree to our "),
                              TextSpan(
                                text: "Terms of Service",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bottom decorative heart
                       Align(
                         alignment: Alignment.bottomRight,
                         child: Icon(
                            Icons.favorite,
                            size: 60,
                            color: AppColors.primaryPink.withOpacity(0.05),
                          ),
                       )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.primaryPink, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
