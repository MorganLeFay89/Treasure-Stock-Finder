import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/features/stock_data/domain/edinet_document.dart';

/// EDINET開示書類データのローカルキャッシュ永続化リポジトリ
class EdinetLocalCacheRepository {
  static const String _edinetDocsCacheKey = 'cached_edinet_docs_map';

  /// 特定の証券コードに紐づくローカル保存済みEDINET書類一覧を取得
  Future<List<EdinetDocument>> getCachedDocuments(String secCode) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_edinetDocsCacheKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      final listDynamic = map[secCode];
      if (listDynamic is List) {
        return listDynamic
            .map((item) => EdinetDocument.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// 特定の証券コードのEDINET書類一覧をローカル保存（上書き更新）
  Future<void> saveDocuments(String secCode, List<EdinetDocument> documents) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_edinetDocsCacheKey);
    Map<String, dynamic> map = {};
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        map = Map<String, dynamic>.from(jsonDecode(jsonStr));
      } catch (_) {}
    }

    map[secCode] = documents.map((doc) => doc.toJson()).toList();
    await prefs.setString(_edinetDocsCacheKey, jsonEncode(map));
  }

  /// 全EDINETキャッシュのクリア
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_edinetDocsCacheKey);
  }
}
