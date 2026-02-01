class AvatarUtils {
  // Using 'adventurer' style for a fun, illustrative look.
  // Options: adventurer, avataaars, bottts, lorelei, notionists, etc.
  static String getAvatarUrl(String name, {String style = 'adventurer'}) {
    // DiceBear 9.x API
    return 'https://api.dicebear.com/9.x/$style/png?seed=${Uri.encodeComponent(name)}';
  }
}
