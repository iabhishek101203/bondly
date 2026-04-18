import 'dart:async';
import 'package:flutter/material.dart';
import 'package:persona_flutter/persona_flutter.dart';
import '../services/verification_service.dart';
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
  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ── Service & State ───────────────────────────────────────────────────────
  final VerificationService _verificationService = VerificationService();
  bool   _isLoading      = false;
  String _loadingMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Validate form fields
  // ─────────────────────────────────────────────────────────────────────────
  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Please enter your email.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text.trim())) {
      return 'Please enter a valid email address.';
    }
    if (_passwordController.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAIN FLOW: Register → Create Inquiry → Persona SDK → Check Status → Navigate
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _onContinuePressed() async {
    // Step 1: Validate form
    final error = _validate();
    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    setState(() {
      _isLoading      = true;
      _loadingMessage = 'Creating your account...';
    });

    try {
      // ⚠️ TEMPORARY BYPASS FOR UI TESTING ⚠️
      // Since you don't have a backend running yet, this will let you skip the 
      // network and Persona steps, so you can actually see the next screen!
      bool isTestingUI = true; 
      
      if (isTestingUI) {
        await Future.delayed(const Duration(seconds: 1)); // Simulate loading
        if (!mounted) return;
        _showSnack('Identity verified (Mocked)! Welcome aboard! 🎉');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InterestsScreen(
              userName: _nameController.text.trim(),
            ),
          ),
        );
        return;
      }
      
      // Step 2: Register Speaker on backend → receives & stores JWT
      await _verificationService.registerSpeaker(
        name:     _nameController.text.trim(),
        email:    _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Step 3: Call backend to create a Persona inquiry session
      setState(() => _loadingMessage = 'Setting up identity verification...');
      final inquiryId = await _verificationService.createInquiry();

      // Step 4: Launch Persona camera SDK with the inquiry ID
      setState(() => _loadingMessage = 'Preparing liveness check...');
      final sdkCompleted = await _launchPersonaSDK(inquiryId);

      // If user cancelled the SDK → stop here, let them retry
      if (!sdkCompleted) {
        _showSnack(
          'Verification cancelled. Please complete it to continue.',
          isError: true,
        );
        setState(() => _isLoading = false);
        return;
      }

      // Step 5: Wait for Persona webhook to update our DB, then poll status
      setState(() => _loadingMessage = 'Confirming your verification...');
      await Future.delayed(const Duration(seconds: 2));
      final status = await _verificationService.getVerificationStatus();

      if (!mounted) return;

      // Step 6: Navigate based on verification result
      if (status['verified'] == true) {
        _showSnack('Identity verified! Welcome aboard! 🎉');
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InterestsScreen(
              userName: _nameController.text.trim(),
            ),
          ),
        );
      } else {
        final currentStatus = status['status'] as String? ?? 'unknown';
        _showSnack(
          'Verification $currentStatus. Please try again.',
          isError: true,
        );
      }
    } on Exception catch (e) {
      _showSnack(
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Launch Persona SDK
  // Returns: true  → SDK ran (completed or failed — webhook handles result)
  //          false → user cancelled
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> _launchPersonaSDK(String inquiryId) async {
    final completer = Completer<bool>();

    StreamSubscription<InquiryComplete>? completeSub;
    StreamSubscription<InquiryCanceled>? canceledSub;
    StreamSubscription<InquiryError>? errorSub;

    void cleanup() {
      completeSub?.cancel();
      canceledSub?.cancel();
      errorSub?.cancel();
    }

    completeSub = PersonaInquiry.onComplete.listen((event) {
      debugPrint('[Persona] onComplete: ${event.inquiryId}');
      cleanup();
      if (!completer.isCompleted) completer.complete(true);
    });

    canceledSub = PersonaInquiry.onCanceled.listen((event) {
      debugPrint('[Persona] onCanceled');
      cleanup();
      if (!completer.isCompleted) completer.complete(false);
    });

    errorSub = PersonaInquiry.onError.listen((event) {
      debugPrint('[Persona] onError: ${event.error}');
      cleanup();
      if (!completer.isCompleted) {
        completer.completeError(Exception('Persona SDK error: ${event.error}'));
      }
    });

    await PersonaInquiry.init(
      configuration: InquiryIdConfiguration(inquiryId: inquiryId),
    );
    PersonaInquiry.start();

    return completer.future;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Styled SnackBar helper
  // ─────────────────────────────────────────────────────────────────────────
  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [

            // ── Main scrollable form ────────────────────────────────────────
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Back button (disabled during loading)
                    GestureDetector(
                      onTap: _isLoading ? null : () => Navigator.pop(context),
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back, size: 20, color: AppColors.textGrey),
                          SizedBox(width: 4),
                          Text(
                            'Back',
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

                    // Form fields
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Email',
                      hint: 'your@email.com',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 20),

                    // Change role link (disabled during loading)
                    GestureDetector(
                      onTap: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text(
                        'Change role',
                        style: TextStyle(
                          color: AppColors.primaryPink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Speaker Liveness Notice ───────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryPink.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.primaryPink,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "As a Speaker, you'll need to complete a quick "
                              "face verification after signing up. "
                              "It only takes 30 seconds.",
                              style: TextStyle(
                                color: AppColors.primaryPink,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Continue Button ───────────────────────────────────
                    CustomButton(
                      text: 'Continue & Verify Identity',
                      onPressed: _isLoading ? null : _onContinuePressed,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ── Full-screen Loading Overlay ─────────────────────────────────
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primaryPink,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _loadingMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

          ], // Stack children
        ),
      ),
    );
  }
}
