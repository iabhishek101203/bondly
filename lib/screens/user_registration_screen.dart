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
  /// 'speaker' or 'listener'
  final String role;

  const UserRegistrationScreen({super.key, required this.role});

  @override
  State<UserRegistrationScreen> createState() =>
      _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  // ── Controllers ───────────────────────────────────────────────────
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  // ── Services ──────────────────────────────────────────────────────
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirestoreService();

  bool _isLoading = false;
  final bool _obscurePassword = true;
  final bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────
  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Please enter your email.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
        .hasMatch(_emailController.text.trim())) {
      return 'Please enter a valid email address.';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (_passwordController.text != _confirmController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  // ── Sign Up ───────────────────────────────────────────────────────
  Future<void> _onSignUp() async {
    final error = _validate();
    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Update display name in Auth
      await credential.user
          ?.updateDisplayName(_nameController.text.trim());

      // 3. Create Firestore user document (50 welcome tokens included)
      await _firestore.createOrUpdateUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      // 4. Navigate to interests screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InterestsScreen(
            userName: _nameController.text.trim(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(_friendlyAuthError(e.code), isError: true);
    } catch (e) {
      _showSnack('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Friendly error messages ───────────────────────────────────────
  String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────
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

                  // ── Back ─────────────────────────────────────────
                  GestureDetector(
                    onTap:
                        _isLoading ? null : () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back,
                            size: 20, color: AppColors.textGrey),
                        SizedBox(width: 4),
                        Text('Back',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ── Header ────────────────────────────────────────
                  Text(
                    isSpeaker ? 'Join as Speaker' : 'Create Account',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSpeaker
                        ? 'Share your knowledge and earn tokens'
                        : 'Connect with amazing people',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 32),

                  // ── Role Badge ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              AppColors.primaryPink.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSpeaker
                              ? Icons.phone_in_talk_outlined
                              : Icons.favorite,
                          color: AppColors.primaryPink,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSpeaker ? 'Speaker' : 'Listener',
                          style: const TextStyle(
                              color: AppColors.primaryPink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Form Fields ───────────────────────────────────
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Email',
                    hint: 'your@email.com',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a password (min 6 characters)',
                    isPassword: _obscurePassword,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    isPassword: _obscureConfirm,
                    controller: _confirmController,
                  ),
                  const SizedBox(height: 32),

                  // ── Sign Up Button ────────────────────────────────
                  CustomButton(
                    text: 'Create Account',
                    onPressed: _isLoading ? null : _onSignUp,
                  ),
                  const SizedBox(height: 20),

                  // ── Sign In Link ──────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SignInScreen()),
                              ),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: AppColors.primaryPink,
                                fontWeight: FontWeight.bold,
                              ),
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

            // ── Loading Overlay ───────────────────────────────────
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: Center(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                            color: AppColors.primaryPink,
                            strokeWidth: 3),
                        SizedBox(height: 20),
                        Text(
                          'Creating your account…',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
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

// ══════════════════════════════════════════════════════════════════════════════
// SIGN IN SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth               = FirebaseAuth.instance;
  final _firestore          = FirestoreService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnack('Please enter your email and password.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Mark user online
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
      _showSnack('Something went wrong. Please try again.', isError: true);
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
      await _auth.sendPasswordResetEmail(
          email: _emailController.text.trim());
      _showSnack('Password reset email sent! Check your inbox.');
    } on FirebaseAuthException catch (e) {
      _showSnack(_friendlyError(e.code), isError: true);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back,
                            size: 20, color: AppColors.textGrey),
                        SizedBox(width: 4),
                        Text('Back',
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Logo
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE94057), Color(0xFFF27121)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.favorite,
                          size: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'Welcome back!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Sign in to continue to Bondly',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textGrey),
                    ),
                  ),
                  const SizedBox(height: 40),

                  CustomTextField(
                    label: 'Email',
                    hint: 'your@email.com',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Password',
                    hint: 'Your password',
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _onForgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: AppColors.primaryPink,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Sign In',
                    onPressed: _isLoading ? null : _onSignIn,
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                  color: AppColors.primaryPink,
                                  fontWeight: FontWeight.bold),
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                            color: AppColors.primaryPink,
                            strokeWidth: 3),
                        SizedBox(height: 20),
                        Text(
                          'Signing you in…',
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
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
