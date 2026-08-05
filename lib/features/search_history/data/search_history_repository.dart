import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/features/search_history/domain/search_history_item.dart';

/// shared_preferencesを利用した検索履歴のリポジトリ
class SearchHistoryRepository {
  static const String _historyKey = 'search_history_items';

  /// 検索履歴一覧を取得（新しい順）
  Future<List<SearchHistoryItem>> getHistoryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_historyKey) ?? [];

    final List<SearchHistoryItem> items = [];
    for (final jsonStr in jsonStringList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        items.add(SearchHistoryItem.fromJson(map));
      } catch (_) {
        // パース失敗した古いデータはスキップ
      }
    }

    // 検索日時の降順（最新順）にソート
    items.sort((a, b) => b.searchDateTime.compareTo(a.searchDateTime));
    return items;
  }

  /// 検索履歴を追加（上限30件）
  Future<void> addHistoryItem(SearchHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getHistoryItems();

    // 重複IDがあれば除去
    currentList.removeWhere((i) => i.id == item.id);
    currentList.insert(0, item);

    // 最大30件保持
    final trimmedList = currentList.take(30).toList();

    final jsonStringList = trimmedList.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonStringList);
  }

  /// 特定の検索履歴を削除
  Future<void> deleteHistoryItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getHistoryItems();
    currentList.removeWhere((item) => item.id == id);

    final jsonStringList = currentList.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonStringList);
  }

  /// すべての検索履歴を削除
  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
