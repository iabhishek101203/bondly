// lib/screens/speaker/speaker_kyc_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/colors.dart';
import '../../models/user_model.dart';

class SpeakerKycScreen extends StatefulWidget {
  final UserModel currentUser;
  const SpeakerKycScreen({super.key, required this.currentUser});

  @override
  State<SpeakerKycScreen> createState() => _SpeakerKycScreenState();
}

class _SpeakerKycScreenState extends State<SpeakerKycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadharController    = TextEditingController();
  final _panController       = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController      = TextEditingController();
  final _bankNameController  = TextEditingController();
  final _upiController       = TextEditingController();
  final _phoneController     = TextEditingController();

  int _currentStep = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _aadharController.dispose();
    _panController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('kyc_requests').doc(uid).set({
        'uid': uid,
        'name': widget.currentUser.name,
        'email': widget.currentUser.email,
        'aadharLast4': _aadharController.text.trim().substring(
          _aadharController.text.trim().length - 4),
        'panNumber': _panController.text.trim().toUpperCase(),
        'bankAccount': _bankAccountController.text.trim(),
        'ifscCode': _ifscController.text.trim().toUpperCase(),
        'bankName': _bankNameController.text.trim(),
        'upiId': _upiController.text.trim(),
        'phone': _phoneController.text.trim(),
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });
      // Update user kycStatus
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'kycStatus': 'pending',
      });
      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 44),
            ),
            const SizedBox(height: 16),
            const Text('KYC Submitted!',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Your documents are under review.\nWe\'ll notify you within 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If already pending/approved show status
    if (widget.currentUser.kycStatus == 'approved') {
      return _buildStatusScreen('approved');
    }
    if (widget.currentUser.kycStatus == 'pending') {
      return _buildStatusScreen('pending');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTopBar(),
              _buildStepIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _currentStep == 0
                      ? _buildStep1Identity()
                      : _currentStep == 1
                          ? _buildStep2Bank()
                          : _buildStep3Review(),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text('KYC Verification',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Identity', 'Bank Details', 'Review'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < _currentStep
                    ? AppColors.primaryPink
                    : Colors.white12,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final done = stepIdx < _currentStep;
          final active = stepIdx == _currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.primaryPink
                      : active
                          ? AppColors.primaryPink.withValues(alpha: 0.2)
                          : Colors.white12,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active || done ? AppColors.primaryPink : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${stepIdx + 1}',
                          style: TextStyle(
                            color: active ? AppColors.primaryPink : Colors.white38,
                            fontWeight: FontWeight.bold, fontSize: 13,
                          )),
                ),
              ),
              const SizedBox(height: 4),
              Text(steps[stepIdx],
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white38,
                    fontSize: 10,
                  )),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep1Identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _sectionTitle('Identity Verification', '🪪'),
        const SizedBox(height: 6),
        const Text('Your details are encrypted and secure',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 24),
        _kycField(
          controller: _aadharController,
          label: 'Aadhar Card Number',
          hint: 'XXXX XXXX XXXX',
          icon: '🪪',
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            final digits = v.replaceAll(' ', '');
            if (digits.length != 12) return 'Aadhar must be 12 digits';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _kycField(
          controller: _panController,
          label: 'PAN Card Number',
          hint: 'ABCDE1234F',
          icon: '📄',
          textCapitalization: TextCapitalization.characters,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v.toUpperCase()))
              return 'Invalid PAN format';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _kycField(
          controller: _phoneController,
          label: 'Phone Number (linked to Aadhar)',
          hint: '+91 XXXXX XXXXX',
          icon: '📱',
          keyboardType: TextInputType.phone,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            final digits = v.replaceAll(RegExp(r'[^\d]'), '');
            if (digits.length < 10) return 'Invalid phone number';
            return null;
          },
        ),
        const SizedBox(height: 24),
        _securityNote(),
      ],
    );
  }

  Widget _buildStep2Bank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _sectionTitle('Bank Account Details', '🏦'),
        const SizedBox(height: 6),
        const Text('Withdrawals will be transferred to this account',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 24),
        _kycField(
          controller: _bankNameController,
          label: 'Bank Name',
          hint: 'e.g. SBI, HDFC, ICICI',
          icon: '🏦',
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _kycField(
          controller: _bankAccountController,
          label: 'Account Number',
          hint: 'Enter your account number',
          icon: '💳',
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (v.trim().length < 9) return 'Invalid account number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _kycField(
          controller: _ifscController,
          label: 'IFSC Code',
          hint: 'e.g. SBIN0001234',
          icon: '🔢',
          textCapitalization: TextCapitalization.characters,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v.toUpperCase()))
              return 'Invalid IFSC code';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _kycField(
          controller: _upiController,
          label: 'UPI ID (Optional)',
          hint: 'yourname@upi',
          icon: '📲',
          validator: (_) => null,
        ),
        const SizedBox(height: 24),
        _securityNote(),
      ],
    );
  }

  Widget _buildStep3Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _sectionTitle('Review & Submit', '✅'),
        const SizedBox(height: 6),
        const Text('Please verify your details before submitting',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 24),
        _reviewCard('Identity Details', [
          {'Aadhar': '•••• •••• ${_aadharController.text.trim().length >= 4 ? _aadharController.text.trim().substring(_aadharController.text.trim().length - 4) : '????'}'},
          {'PAN': _panController.text.trim().toUpperCase()},
          {'Phone': _phoneController.text.trim()},
        ]),
        const SizedBox(height: 16),
        _reviewCard('Bank Details', [
          {'Bank': _bankNameController.text.trim()},
          {'Account': '•••• ${_bankAccountController.text.trim().length >= 4 ? _bankAccountController.text.trim().substring(_bankAccountController.text.trim().length - 4) : '????'}'},
          {'IFSC': _ifscController.text.trim().toUpperCase()},
          if (_upiController.text.trim().isNotEmpty)
            {'UPI': _upiController.text.trim()},
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚠️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By submitting, you confirm that all details are accurate. '
                  'False information may result in account suspension.',
                  style: TextStyle(color: Colors.orange, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewCard(String title, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.keys.first, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                Text(item.values.first, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.of(context).padding.bottom + 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back', style: TextStyle(color: Colors.white70, fontSize: 15)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (_currentStep < 2) {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _currentStep++);
                        }
                      } else {
                        _submitKyc();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                disabledBackgroundColor: AppColors.primaryPink.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _currentStep < 2 ? 'Continue →' : 'Submit KYC',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusScreen(String status) {
    final isApproved = status == 'approved';
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: isApproved
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isApproved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                  color: isApproved ? Colors.green : Colors.orange,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isApproved ? 'KYC Verified ✅' : 'Under Review ⏳',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                isApproved
                    ? 'Your identity has been verified.\nYou can now withdraw your earnings anytime!'
                    : 'Your KYC documents are being reviewed.\nThis usually takes up to 24 hours.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 15, height: 1.5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: const Text('Go Back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _kycField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _securityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_rounded, color: Colors.blue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your data is encrypted and stored securely. We never share your personal information.',
              style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
