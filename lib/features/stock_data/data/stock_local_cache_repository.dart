import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/stock_data/domain/stock_master.dart';

/// 銘柄データのローカルキャッシュ永続化リポジトリ
class StockLocalCacheRepository {
  static const String _stocksCacheKey = 'cached_stocks_data_map';
  static const String _stocksUpdatedTimeKey = 'cached_stocks_updated_time_map';
  static const String _syncIndexKey = 'sync_current_index';

  /// コード表記を正規化（5桁末尾0 -> 4桁）
  String _normalizeCode(String code) {
    if (code.length == 5 && code.endsWith('0')) return code.substring(0, 4);
    return code;
  }

  /// ローカルに保存されているすべての銘柄リストを取得
  Future<List<Stock>> getCachedStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_stocksCacheKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      final List<Stock> list = [];
      for (final value in map.values) {
        if (value is Map<String, dynamic>) {
          list.add(Stock.fromJson(value));
        }
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  /// 単一銘柄のデータをローカル保存（最終更新日時も合わせて記録）
  Future<void> saveStock(Stock stock) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_stocksCacheKey);
    Map<String, dynamic> map = {};
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        map = Map<String, dynamic>.from(jsonDecode(jsonStr));
      } catch (_) {}
    }

    map[_normalizeCode(stock.stockCode)] = stock.toJson();
    await prefs.setString(_stocksCacheKey, jsonEncode(map));

    // 更新日時の記録
    final timeJsonStr = prefs.getString(_stocksUpdatedTimeKey);
    Map<String, dynamic> timeMap = {};
    if (timeJsonStr != null && timeJsonStr.isNotEmpty) {
      try {
        timeMap = Map<String, dynamic>.from(jsonDecode(timeJsonStr));
      } catch (_) {}
    }
    timeMap[_normalizeCode(stock.stockCode)] = DateTime.now().toIso8601String();
    await prefs.setString(_stocksUpdatedTimeKey, jsonEncode(timeMap));
  }

  /// 各銘柄の最終更新日時マップを取得
  Future<Map<String, DateTime>> getUpdatedTimeMap() async {
    final prefs = await SharedPreferences.getInstance();
    final timeJsonStr = prefs.getString(_stocksUpdatedTimeKey);
    if (timeJsonStr == null || timeJsonStr.isEmpty) return {};

    try {
      final Map<String, dynamic> map = jsonDecode(timeJsonStr);
      final Map<String, DateTime> result = {};
      map.forEach((code, isoStr) {
        final dt = DateTime.tryParse(isoStr.toString());
        if (dt != null) {
          result[_normalizeCode(code)] = dt;
        }
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  /// 「データ未存在の銘柄」最優先 ➔ 「更新日時が最も古い銘柄」順で次の同期ターゲットを選出
  Future<StockMaster?> getNextSyncTarget(List<StockMaster> allMasters) async {
    if (allMasters.isEmpty) return null;

    final cachedStocks = await getCachedStocks();
    final cachedCodes = cachedStocks.map((s) => _normalizeCode(s.stockCode)).toSet();

    // 1. まだローカルに保存されていない（未取得）銘柄があれば、コードの若い順に最優先取得
    final unsyncedMasters = allMasters.where((m) => !cachedCodes.contains(_normalizeCode(m.code))).toList();
    if (unsyncedMasters.isNotEmpty) {
      unsyncedMasters.sort((a, b) => a.code.compareTo(b.code));
      return unsyncedMasters.first;
    }

    // 2. 全銘柄が保存済みの場合は、最終更新日時が「最も古い銘柄」を次の同期ターゲットにする
    final timeMap = await getUpdatedTimeMap();
    allMasters.sort((a, b) {
    final timeA = timeMap[_normalizeCode(a.code)] ?? DateTime.fromMillisecondsSinceEpoch(0);
    final timeB = timeMap[_normalizeCode(b.code)] ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeA.compareTo(timeB);
    });

    return allMasters.first;
  }

  /// キャッシュ件数の取得
  Future<int> getCachedCount() async {
    final stocks = await getCachedStocks();
    return stocks.length;
  }

  /// 互換用インデックス保存
  Future<void> saveSyncIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_syncIndexKey, index);
  }

  /// ローカルに保存した銘柄キャッシュと同期状態をすべて削除
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stocksCacheKey);
    await prefs.remove(_stocksUpdatedTimeKey);
    await prefs.remove(_syncIndexKey);
  }
}
