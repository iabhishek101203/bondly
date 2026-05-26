// lib/models/gift_model.dart

class GiftItem {
  final String id;
  final String name;
  final String emoji;
  final int tokens;
  final String category;

  const GiftItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tokens,
    required this.category,
  });

  static const List<GiftItem> all = [
    GiftItem(id: 'rose',      name: 'Rose',       emoji: '🌹', tokens: 10,   category: 'basic'),
    GiftItem(id: 'heart',     name: 'Heart',      emoji: '❤️', tokens: 15,   category: 'basic'),
    GiftItem(id: 'kiss',      name: 'Kiss',       emoji: '💋', tokens: 20,   category: 'basic'),
    GiftItem(id: 'cake',      name: 'Cake',       emoji: '🎂', tokens: 25,   category: 'basic'),
    GiftItem(id: 'bouquet',   name: 'Bouquet',    emoji: '💐', tokens: 30,   category: 'basic'),
    GiftItem(id: 'chocolate', name: 'Chocolate',  emoji: '🍫', tokens: 35,   category: 'basic'),
    GiftItem(id: 'teddy',     name: 'Teddy Bear', emoji: '🧸', tokens: 50,   category: 'premium'),
    GiftItem(id: 'crown',     name: 'Crown',      emoji: '👑', tokens: 75,   category: 'premium'),
    GiftItem(id: 'trophy',    name: 'Trophy',     emoji: '🏆', tokens: 100,  category: 'premium'),
    GiftItem(id: 'guitar',    name: 'Guitar',     emoji: '🎸', tokens: 150,  category: 'premium'),
    GiftItem(id: 'perfume',   name: 'Perfume',    emoji: '🧴', tokens: 200,  category: 'premium'),
    GiftItem(id: 'watch',     name: 'Watch',      emoji: '⌚', tokens: 250,  category: 'premium'),
    GiftItem(id: 'ring',      name: 'Ring',       emoji: '💍', tokens: 500,  category: 'luxury'),
    GiftItem(id: 'sportscar', name: 'Sports Car', emoji: '🏎️', tokens: 1000, category: 'luxury'),
    GiftItem(id: 'rocket',    name: 'Rocket',     emoji: '🚀', tokens: 2000, category: 'luxury'),
    GiftItem(id: 'island',    name: 'Island',     emoji: '🏝️', tokens: 5000, category: 'luxury'),
  ];

  static List<GiftItem> byCategory(String cat) =>
      all.where((g) => g.category == cat).toList();
}
