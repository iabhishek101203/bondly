import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'interests_screen.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true, // Allow keyboard to push content up
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

                // Form Fields
                CustomTextField(
                  label: "Full Name",
                  hint: "Enter your name",
                  controller: _nameController,
                ),
                const SizedBox(height: 20),
                 CustomTextField(
                  label: "Email",
                  hint: "your@email.com",
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                 CustomTextField(
                  label: "Password",
                  hint: "Create a password",
                  isPassword: true,
                  controller: _passwordController,
                ),
                
                const SizedBox(height: 20),
                
                // Change Role Link
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Change role",
                    style: TextStyle(
                      color: AppColors.primaryPink,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Continue Button
                CustomButton(
                  text: "Continue",
                  onPressed: () {
                    if (_nameController.text.trim().isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InterestsScreen(userName: _nameController.text.trim()),
                        ),
                      );
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your full name to continue")),
                      );
                    }
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
