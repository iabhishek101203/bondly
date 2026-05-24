// lib/utils/token_package.dart

class TokenPackage {
  final String id;
  final int tokens;
  final double priceInr;
  final String label;
  final String? badge;
  final int? bonusTokens;

  const TokenPackage({
    required this.id,
    required this.tokens,
    required this.priceInr,
    required this.label,
    this.badge,
    this.bonusTokens,
  });

  int get totalTokens => tokens + (bonusTokens ?? 0);

  String get priceLabel => '₹${priceInr.toStringAsFixed(0)}';

  static const List<TokenPackage> packages = [
    TokenPackage(id: 'starter',  tokens: 50,   priceInr: 49,   label: 'Starter'),
    TokenPackage(id: 'basic',    tokens: 120,  priceInr: 99,   label: 'Basic',   bonusTokens: 10),
    TokenPackage(id: 'popular',  tokens: 300,  priceInr: 199,  label: 'Popular', badge: 'Popular',    bonusTokens: 40),
    TokenPackage(id: 'value',    tokens: 650,  priceInr: 399,  label: 'Value',   badge: 'Best Value', bonusTokens: 100),
    TokenPackage(id: 'pro',      tokens: 1400, priceInr: 799,  label: 'Pro',     bonusTokens: 250),
    TokenPackage(id: 'elite',    tokens: 3000, priceInr: 1499, label: 'Elite',   badge: 'Save 40%',   bonusTokens: 700),
  ];
}
