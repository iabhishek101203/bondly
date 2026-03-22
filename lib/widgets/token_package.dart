// lib/utils/token_package.dart

enum BadgeType { none, popular, bestValue, save }

class TokenPackage {
  final String id;
  final int coinAmount;
  final int bonusCoins;       // extra bonus coins on top
  final double price;         // in ₹
  final double? originalPrice; // if there's a strikethrough price
  final BadgeType badge;
  final String? savePercent;  // e.g. "45%" shown on Save badge
  final bool isHighlighted;   // visually larger / featured card

  const TokenPackage({
    required this.id,
    required this.coinAmount,
    this.bonusCoins = 0,
    required this.price,
    this.originalPrice,
    this.badge = BadgeType.none,
    this.savePercent,
    this.isHighlighted = false,
  });

  // ── Total coins user actually gets ───────────────────────────────
  int get totalCoins => coinAmount + bonusCoins;

  // ── Badge label string ────────────────────────────────────────────
  String get badgeLabel {
    switch (badge) {
      case BadgeType.popular:
        return 'Popular';
      case BadgeType.bestValue:
        return 'Best Value';
      case BadgeType.save:
        return 'Save ${savePercent ?? ''}';
      case BadgeType.none:
        return '';
    }
  }

  // ── Price display string ──────────────────────────────────────────
  String get priceLabel => '₹${price.toStringAsFixed(0)}';

  // ── Original price display string (for strikethrough) ────────────
  String? get originalPriceLabel =>
      originalPrice != null ? '₹${originalPrice!.toStringAsFixed(0)}' : null;

  // ── Static list of all packages ──────────────────────────────────
  static const List<TokenPackage> packages = [
    TokenPackage(
      id: 'pkg_1',
      coinAmount: 50,
      bonusCoins: 0,
      price: 49,
      badge: BadgeType.none,
      isHighlighted: false,
    ),
    TokenPackage(
      id: 'pkg_2',
      coinAmount: 150,
      bonusCoins: 10,
      price: 129,
      originalPrice: 149,
      badge: BadgeType.none,
      isHighlighted: false,
    ),
    TokenPackage(
      id: 'pkg_3',
      coinAmount: 300,
      bonusCoins: 30,
      price: 249,
      originalPrice: 299,
      badge: BadgeType.popular,
      isHighlighted: false,
    ),
    TokenPackage(
      id: 'pkg_4',
      coinAmount: 500,
      bonusCoins: 75,
      price: 399,
      originalPrice: 499,
      badge: BadgeType.bestValue,
      isHighlighted: true, // featured / larger card
    ),
    TokenPackage(
      id: 'pkg_5',
      coinAmount: 1000,
      bonusCoins: 200,
      price: 749,
      originalPrice: 999,
      badge: BadgeType.save,
      savePercent: '25%',
      isHighlighted: false,
    ),
    TokenPackage(
      id: 'pkg_6',
      coinAmount: 2000,
      bonusCoins: 900,
      price: 1299,
      originalPrice: 2399,
      badge: BadgeType.save,
      savePercent: '45%',
      isHighlighted: false,
    ),
  ];
}