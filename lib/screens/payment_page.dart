// lib/screens/payment_page.dart

import 'package:bondly/utils/token_package.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/firestore_service.dart';

class PaymentPage extends StatefulWidget {
  final TokenPackage package;

  const PaymentPage({super.key, required this.package});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedMethod = 0; // 0=UPI, 1=Card, 2=Netbanking
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'icon': Icons.account_balance_wallet_outlined, 'label': 'UPI'},
    {'icon': Icons.credit_card_outlined, 'label': 'Card'},
    {'icon': Icons.account_balance_outlined, 'label': 'Netbanking'},
  ];

  Future<void> _onPay() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    // TODO: Integrate Razorpay here
    await Future.delayed(const Duration(seconds: 2));

    // For now: directly credit tokens (replace with Razorpay verification)
    try {
      await _firestoreService.addTokens(widget.package.totalTokens);
      if (!mounted) return;

      // Success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.package.totalTokens} tokens have been\nadded to your wallet 🎉',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // close payment page
                    Navigator.pop(context); // close add tokens screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textDark),
                  ),
                  const Text(
                    'Checkout',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Order Summary ──────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.headerGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🪙',
                              style: TextStyle(fontSize: 40)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.package.totalTokens} Tokens',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                if (widget.package.bonusTokens != null)
                                  Text(
                                    'Includes +${widget.package.bonusTokens} bonus tokens',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${widget.package.priceInr.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Payment Method ─────────────────────────
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: List.generate(
                          _paymentMethods.length,
                          (i) => Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedMethod = i),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        right:
                                            i < _paymentMethods.length - 1
                                                ? 10
                                                : 0),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: _selectedMethod == i
                                          ? AppColors.primaryPink
                                              .withOpacity(0.08)
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _selectedMethod == i
                                            ? AppColors.primaryPink
                                            : Colors.grey.shade200,
                                        width: _selectedMethod == i
                                            ? 2
                                            : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          _paymentMethods[i]['icon']
                                              as IconData,
                                          color: _selectedMethod == i
                                              ? AppColors.primaryPink
                                              : AppColors.textGrey,
                                          size: 22,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _paymentMethods[i]['label']
                                              as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedMethod == i
                                                ? AppColors.primaryPink
                                                : AppColors.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                    ),
                    const SizedBox(height: 28),

                    // ── Price Breakdown ────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _priceRow('Tokens',
                              '${widget.package.tokens}'),
                          if (widget.package.bonusTokens != null) ...[
                            const SizedBox(height: 8),
                            _priceRow(
                                'Bonus Tokens',
                                '+${widget.package.bonusTokens}',
                                valueColor: Colors.green),
                          ],
                          const Divider(height: 20),
                          _priceRow(
                            'Total',
                            '₹${widget.package.priceInr.toStringAsFixed(0)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Security note ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_rounded,
                            size: 13, color: AppColors.textGrey),
                        SizedBox(width: 5),
                        Text(
                          '100% Secure · Powered by Razorpay',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Pay Button ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    disabledBackgroundColor:
                        AppColors.primaryPink.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 4,
                    shadowColor: AppColors.primaryPink.withOpacity(0.4),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'Pay ₹${widget.package.priceInr.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ??
                (isBold ? AppColors.textDark : AppColors.textGrey),
          ),
        ),
      ],
    );
  }
}
