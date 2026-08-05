import 'package:finance/core/api_client.dart';
import 'package:finance/core/api_error.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_data/domain/edinet_document.dart';

/// EDINET API v2 通信用クライアント
///
/// 金融庁EDINETの書類一覧API・書類取得APIを利用して、
/// 有価証券報告書・四半期報告書等のメタデータを取得します。
class EdinetApiClient {
  static const String _baseUrl = 'https://api.edinet-fsa.go.jp/api/v2';
  final ApiClient _client;

  EdinetApiClient({ApiClient? client}) : _client = client ?? ApiClient();

  /// 指定日の書類一覧を取得
  ///
  /// [date] 取得対象日 (YYYY-MM-DD)
  /// [type] 取得タイプ (1: メタデータのみ, 2: 添付書類一覧含む)
  Future<List<EdinetDocument>> fetchDocumentList({
    required String date,
    int type = 2,
  }) async {
    if (!EnvConfig.isEdinetApiKeySet) {
      throw ApiAuthException('EDINET APIキーが設定されていません。.env_secrets/.env を確認してください。');
    }

    final uri = Uri.parse(
      '$_baseUrl/documents.json?date=$date&type=$type&Subscription-Key=${EnvConfig.edinetApiKey}',
    );

    final response = await _client.get(uri);

    if (response is Map && response.containsKey('results')) {
      final results = response['results'] as List;
      return results
          .map((json) => EdinetDocument.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// 証券コードを基に、指定期間内の書類を検索
  ///
  /// EDINETの書類一覧APIは日付指定のため、
  /// 直近の日付を遡りながら対象銘柄の書類を探索します。
  Future<List<EdinetDocument>> searchDocumentsBySecCode({
    required String secCode,
    int searchDaysBack = 365,
  }) async {
    if (!EnvConfig.isEdinetApiKeySet) {
      throw ApiAuthException('EDINET APIキーが設定されていません。');
    }

    // 証券コードを5桁に変換（EDINET形式: 4桁コード + "0"）
    final edinetSecCode = secCode.length == 4 ? '${secCode}0' : secCode;

    final List<EdinetDocument> matchedDocuments = [];
    final now = DateTime.now();

    // 直近1年間を30日ずつ遡って検索（API負荷軽減のため間引き）
    for (int daysBack = 0; daysBack < searchDaysBack; daysBack += 30) {
      final targetDate = now.subtract(Duration(days: daysBack));
      final dateStr =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      try {
        final docs = await fetchDocumentList(date: dateStr);
        final matched = docs.where((doc) =>
            doc.secCode == edinetSecCode &&
            (doc.isAnnualReport || doc.isQuarterlyReport || doc.isSemiAnnualReport));
        matchedDocuments.addAll(matched);
      } on ApiException {
        // 特定日のエラーはスキップして次の日付へ
        continue;
      }

      // 有報が見つかったら早期終了
      if (matchedDocuments.any((doc) => doc.isAnnualReport)) {
        break;
      }
    }

    // 提出日の降順でソート
    matchedDocuments.sort((a, b) => b.submitDateTime.compareTo(a.submitDateTime));
    return matchedDocuments;
  }
}
