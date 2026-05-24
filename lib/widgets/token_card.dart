// lib/widgets/token_card.dart

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/token_package.dart';

class TokenCard extends StatelessWidget {
  final TokenPackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const TokenCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.selectedGlow
                  : AppColors.cardShadow,
              blurRadius: isSelected ? 16 : 8,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected ? AppColors.selectedCardGradient : null,
            color: isSelected ? null : AppColors.cardWhite,
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isSelected ? AppColors.selectedBg : AppColors.cardWhite,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Badge ──────────────────────────────────────────
                if (package.badge != null)
                  _buildBadge(package.badge!)
                else
                  const SizedBox(height: 20),

                const SizedBox(height: 8),

                // ── Coin Visual ────────────────────────────────────
                _buildCoinVisual(),

                const SizedBox(height: 10),

                // ── Token Amount ───────────────────────────────────
                Text(
                  '${package.totalTokens}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'Tokens',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),

                // ── Bonus label ────────────────────────────────────
                if (package.bonusTokens != null && package.bonusTokens! > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${package.bonusTokens} Bonus',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                Container(height: 1, color: isSelected ? AppColors.roseLight : AppColors.cardBorder),

                const SizedBox(height: 10),

                // ── Price ──────────────────────────────────────────
                Text(
                  package.priceLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.primaryPink : AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                // ── Select Button ──────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 32,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: isSelected ? AppColors.ctaButtonGradient : null,
                    color: isSelected ? null : AppColors.lavenderSoft,
                  ),
                  child: Center(
                    child: Text(
                      isSelected ? 'Selected ✓' : 'Select',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.lavenderDeep,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinVisual() {
    return SizedBox(
      height: 54,
      width: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
            ),
            child: const Center(
              child: Text(
                '₹',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 14,
            child: Container(
              height: 8,
              width: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    LinearGradient gradient;
    if (label == 'Popular') {
      gradient = AppColors.popularGradient;
    } else if (label == 'Best Value') {
      gradient = AppColors.bestValueGradient;
    } else {
      gradient = const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
