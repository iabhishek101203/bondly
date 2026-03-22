import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPink = Color(0xFFE94057);
  static const Color background = Color(0xFFFDF2F5);
  static const Color textDark = Color(0xFF323232);
  static const Color textGrey = Color(0xFF888888);
  static const Color secondaryPink = Color(0xFFFF7D91);


  // ── Token Screen – Background ──────────────────────────────────────
  static const Color tokenBg         = Color(0xFFF5F0FF); // soft lavender white
  static const Color tokenBgDeep     = Color(0xFFEDE4FF); // slightly deeper lavender

  // ── Token Screen – Lavender Palette ───────────────────────────────
  static const Color lavender        = Color(0xFFB39DDB);
  static const Color lavenderLight   = Color(0xFFD1C4E9);
  static const Color lavenderDeep    = Color(0xFF7E57C2);
  static const Color lavenderSoft    = Color(0xFFEDE7F6);
 // ── Token Screen – Rose / Pink Palette ────────────────────────────
  static const Color rose            = Color(0xFFE91E8C);
  static const Color roseSoft        = Color(0xFFFFB3C6);
  static const Color roseLight       = Color(0xFFFFD6E4);

  // ── Token Screen – Gold / Coin Palette ────────────────────────────
  static const Color goldDark        = Color(0xFFB8860B);
  static const Color goldMid         = Color(0xFFFFAB00);
  static const Color goldLight       = Color(0xFFFFD740);
  static const Color goldShimmer     = Color(0xFFFFF176);

  // ── Token Screen – Card & Surface ────────────────────────────────
  static const Color cardWhite       = Color(0xFFFFFFFF);
  static const Color cardBorder      = Color(0xFFEEE8FF);
  static const Color cardShadow      = Color(0x1A7E57C2); // lavender shadow 10%

  // ── Token Screen – Selected State ────────────────────────────────
  static const Color selectedBorder  = Color(0xFFE94057); // your primaryPink
  static const Color selectedGlow    = Color(0x33E94057); // primaryPink 20%
  static const Color selectedBg      = Color(0xFFFFF0F3); // very soft pink tint

  // ── Token Screen – Badge Colors ───────────────────────────────────
  static const Color badgePopular    = Color(0xFFE94057); // primaryPink
  static const Color badgeBestValue  = Color(0xFF7E57C2); // lavenderDeep
  static const Color badgeSave       = Color(0xFF2E7D32); // green for savings

  // ── Token Screen – Status Colors ──────────────────────────────────
  static const Color success         = Color(0xFF43A047);
  static const Color successLight    = Color(0xFFE8F5E9);
  static const Color error           = Color(0xFFE53935);
  static const Color errorLight      = Color(0xFFFFEBEE);
  static const Color processingColor = Color(0xFF7E57C2);

  // ── Token Screen – Gradients ──────────────────────────────────────

  /// Main screen background gradient (top to bottom)
  static const LinearGradient tokenBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDE4FF), Color(0xFFFDF2F5)],
  );

  /// Selected card border gradient (lavender → rose)
  static const LinearGradient selectedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB39DDB), Color(0xFFE94057)],
  );

  /// CTA button gradient (rose → primaryPink)
  static const LinearGradient ctaButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF7D91), Color(0xFFE94057)],
  );

  /// Gold coin shimmer gradient
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD740), Color(0xFFFFAB00), Color(0xFFB8860B)],
  );

  /// Wallet header gradient
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7E57C2), Color(0xFFE94057)],
  );

  /// Popular badge gradient
  static const LinearGradient popularGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE94057), Color(0xFFFF7D91)],
  );

  /// Best Value badge gradient
  static const LinearGradient bestValueGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)],
  );
}


