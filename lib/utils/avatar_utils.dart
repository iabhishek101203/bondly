// lib/utils/avatar_utils.dart

class AvatarUtils {
  static String getAvatarUrl(String name, {String style = 'adventurer'}) {
    return 'https://api.dicebear.com/9.x/$style/png?seed=${Uri.encodeComponent(name)}';
  }
}
