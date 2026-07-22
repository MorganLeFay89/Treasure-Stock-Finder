import 'package:shared_preferences/shared_preferences.dart';

class FavoriteRepository {
  static const _favoritesKey = 'favorite_stock_codes';

  /// ローカルストレージからお気に入り銘柄コードのリストを取得
  Future<List<String>> getFavoriteCodes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  /// お気に入り銘柄コードを追加
  Future<void> addFavorite(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final codes = prefs.getStringList(_favoritesKey) ?? [];
    if (!codes.contains(code)) {
      codes.add(code);
      await prefs.setStringList(_favoritesKey, codes);
    }
  }

  /// お気に入り銘柄コードを削除
  Future<void> removeFavorite(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final codes = prefs.getStringList(_favoritesKey) ?? [];
    if (codes.contains(code)) {
      codes.remove(code);
      await prefs.setStringList(_favoritesKey, codes);
    }
  }
}
