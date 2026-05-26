// lib/screens/user_registration_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'interests_screen.dart';
import 'home_screen.dart';

class UserRegistrationScreen extends StatefulWidget {
  final String role; // 'speaker' | 'listener'
  const UserRegistrationScreen({super.key, required this.role});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirestoreService();

  bool _isLoading = false;
  String _selectedGender = 'other';
  String _selectedPreference = 'any';

  final List<Map<String, String>> _genders = [
    {'value': 'male',   'label': 'Male',   'emoji': '👨'},
    {'value': 'female', 'label': 'Female', 'emoji': '👩'},
    {'value': 'other',  'label': 'Other',  'emoji': '🧑'},
  ];

  final List<Map<String, String>> _preferences = [
    {'value': 'male',   'label': 'Males',   'emoji': '👨'},
    {'value': 'female', 'label': 'Females', 'emoji': '👩'},
    {'value': 'any',    'label': 'Anyone',  'emoji': '🌈'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'Please enter your full name.';
    if (_emailController.text.trim().isEmpty) return 'Please enter your email.';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text.trim()))
      return 'Please enter a valid email address.';
    if (_passwordController.text.length < 6) return 'Password must be at least 6 characters.';
    if (_passwordController.text != _confirmController.text) return 'Passwords do not match.';
    return null;
  }

  Future<void> _onSignUp() async {
    final error = _validate();
    if (error != null) { _showSnack(error, isError: true); return; }
    setState(() => _isLoading = true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await credential.user?.updateDisplayName(_nameController.text.trim());
      await _firestore.createOrUpdateUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: widget.role,
        gender: _selectedGender,
        preference: _selectedPreference,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InterestsScreen(userName: _nameController.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(_friendlyError(e.code), isError: true);
    } catch (e) {
      _showSnack('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password': return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed': return 'No internet connection.';
      default: return 'Registration failed. Please try again.';
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaker = widget.role == 'speaker';
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _isLoading ? null : () => Navigator.pop(context),
                    child: const Row(children: [
                      Icon(Icons.arrow_back, size: 20, color: AppColors.textGrey),
                      SizedBox(width: 4),
                      Text('Back', style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSpeaker
                          ? Colors.purple.withValues(alpha: 0.1)
                          : AppColors.primaryPink.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSpeaker
                            ? Colors.purple.withValues(alpha: 0.3)
                            : AppColors.primaryPink.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isSpeaker ? '🎙️' : '🎧',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          isSpeaker ? 'Registering as Speaker' : 'Registering as Listener',
                          style: TextStyle(
                            color: isSpeaker ? Colors.purple : AppColors.primaryPink,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    isSpeaker ? 'Join as Speaker' : 'Create Account',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSpeaker
                        ? 'Go live, connect with people & earn tokens'
                        : 'Connect with amazing speakers',
                    style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 28),

                  CustomTextField(label: 'Full Name', hint: 'Enter your name', controller: _nameController),
                  const SizedBox(height: 16),
                  CustomTextField(label: 'Email', hint: 'your@email.com', controller: _emailController),
                  const SizedBox(height: 16),
                  CustomTextField(label: 'Password', hint: 'Min 6 characters', isPassword: true, controller: _passwordController),
                  const SizedBox(height: 16),
                  CustomTextField(label: 'Confirm Password', hint: 'Re-enter password', isPassword: true, controller: _confirmController),
                  const SizedBox(height: 24),

                  // Gender selection
                  const Text('I am a',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: _genders.map((g) {
                      final selected = _selectedGender == g['value'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = g['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryPink.withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? AppColors.primaryPink : Colors.grey.shade200,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(g['emoji']!, style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 4),
                                Text(g['label']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? AppColors.primaryPink : AppColors.textGrey,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Preference selection
                  const Text('I want to connect with',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: _preferences.map((p) {
                      final selected = _selectedPreference == p['value'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPreference = p['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryPink.withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? AppColors.primaryPink : Colors.grey.shade200,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(p['emoji']!, style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 4),
                                Text(p['label']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? AppColors.primaryPink : AppColors.textGrey,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Create Account',
                    onPressed: _isLoading ? null : _onSignUp,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SignInScreen())),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                        color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryPink, strokeWidth: 3),
                        SizedBox(height: 20),
                        Text('Creating your account…',
                            style: TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Sign In Screen ─────────────────────────────────────────────────────────────

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirestoreService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showSnack('Please enter your email and password.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _firestore.setOnlineStatus(true);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(_friendlyError(e.code), isError: true);
    } catch (e) {
      _showSnack('Something went wrong.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnack('Enter your email above first.', isError: true);
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showSnack('Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      _showSnack(_friendlyError(e.code), isError: true);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':   return 'No account found with this email.';
      case 'wrong-password':   return 'Incorrect password.';
      case 'too-many-requests':return 'Too many attempts. Try again later.';
      default:                 return 'Sign in failed. Please try again.';
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE94057), Color(0xFFF27121)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(
                          color: AppColors.primaryPink.withValues(alpha: 0.3),
                          blurRadius: 16, offset: const Offset(0, 8),
                        )],
                      ),
                      child: const Icon(Icons.favorite, size: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(child: Text('Welcome back!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                  const SizedBox(height: 8),
                  const Center(child: Text('Sign in to continue to Bondly',
                      style: TextStyle(fontSize: 14, color: AppColors.textGrey))),
                  const SizedBox(height: 40),
                  CustomTextField(label: 'Email', hint: 'your@email.com', controller: _emailController),
                  const SizedBox(height: 16),
                  CustomTextField(label: 'Password', hint: 'Your password', isPassword: true, controller: _passwordController),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _onForgotPassword,
                      child: const Text('Forgot Password?',
                          style: TextStyle(color: AppColors.primaryPink, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(text: 'Sign In', onPressed: _isLoading ? null : _onSignIn),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                          children: [TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold),
                          )],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                        color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(color: AppColors.primaryPink, strokeWidth: 3),
                      SizedBox(height: 20),
                      Text('Signing you in…',
                          style: TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
