// lib/widgets/token_card.dart

import 'package:bondly/utils/colors.dart';
import 'package:bondly/widgets/token_package.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
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
          // Glow effect when selected
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.selectedGlow,
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Gradient border when selected
            gradient: isSelected ? AppColors.selectedCardGradient : null,
            color: isSelected ? null : AppColors.cardWhite,
          ),
          padding: const EdgeInsets.all(2), // border thickness
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
                // ── Badge ─────────────────────────────────────────
                if (package.badge != BadgeType.none)
                  _buildBadge()
                else
                  const SizedBox(height: 20),

                const SizedBox(height: 8),

                // ── Coin Visual ───────────────────────────────────
                _buildCoinVisual(),

                const SizedBox(height: 10),

                // ── Coin Amount ───────────────────────────────────
                Text(
                  '${package.totalCoins}',
                  style: TextStyle(
                    fontSize: package.isHighlighted ? 26 : 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 2),

                // ── "Coins" label ─────────────────────────────────
                Text(
                  'Coins',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),

                // ── Bonus label ───────────────────────────────────
                if (package.bonusCoins > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${package.bonusCoins} Bonus',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // ── Divider ───────────────────────────────────────
                Container(
                  height: 1,
                  color: isSelected
                      ? AppColors.roseLight
                      : AppColors.cardBorder,
                ),

                const SizedBox(height: 10),

                // ── Price ─────────────────────────────────────────
                Text(
                  package.priceLabel,
                  style: TextStyle(
                    fontSize: package.isHighlighted ? 18 : 16,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? AppColors.primaryPink
                        : AppColors.textDark,
                  ),
                ),

                // ── Original Price (strikethrough) ────────────────
                if (package.originalPriceLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    package.originalPriceLabel!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // ── Select Button ─────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 32,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: isSelected
                        ? AppColors.ctaButtonGradient
                        : null,
                    color: isSelected ? null : AppColors.lavenderSoft,
                  ),
                  child: Center(
                    child: Text(
                      isSelected ? 'Selected ✓' : 'Select',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.lavenderDeep,
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

  // ── Coin Visual Builder ─────────────────────────────────────────────
  Widget _buildCoinVisual() {
    return SizedBox(
      height: 60,
      width: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow circle
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.goldLight.withOpacity(0.3),
                  AppColors.goldMid.withOpacity(0.0),
                ],
              ),
            ),
          ),
          // Main coin circle
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.goldShimmer,
                  AppColors.goldLight,
                  AppColors.goldMid,
                  AppColors.goldDark,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldMid.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.goldGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Shine highlight on coin
          Positioned(
            top: 10,
            left: 14,
            child: Container(
              height: 10,
              width: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Badge Builder ───────────────────────────────────────────────────
  Widget _buildBadge() {
    LinearGradient badgeGradient;
    String label = package.badgeLabel;

    switch (package.badge) {
      case BadgeType.popular:
        badgeGradient = AppColors.popularGradient;
        break;
      case BadgeType.bestValue:
        badgeGradient = AppColors.bestValueGradient;
        break;
      case BadgeType.save:
        badgeGradient = const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
        );
        break;
      case BadgeType.none:
        badgeGradient = AppColors.popularGradient;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: badgeGradient,
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