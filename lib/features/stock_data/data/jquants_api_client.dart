import 'package:finance/core/api_client.dart';
import 'package:finance/core/api_error.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_data/domain/daily_stock_price.dart';
import 'package:finance/features/stock_data/domain/financial_summary.dart';
import 'package:finance/features/stock_data/domain/stock_master.dart';

/// J-Quants API V2 通信用クライアント（APIキー認証）
class JQuantsApiClient {
  static const String _baseUrl = 'https://api.jquants.com/v2';
  final ApiClient _client;

  JQuantsApiClient({ApiClient? client}) : _client = client ?? ApiClient();

  Map<String, String> _headers() {
    if (!EnvConfig.isJquantsApiKeySet) {
      throw ApiAuthException(
        'J-Quants APIキーが設定されていません。.env_secrets/.env を確認してください。',
      );
    }
    return {'x-api-key': EnvConfig.jquantsApiKey};
  }

  /// 5桁コード（例: 13010）を4桁コード（例: 1301）に正規化
  static String normalizeCode(String code) {
    final trimmed = code.trim();
    if (trimmed.length == 5 && trimmed.endsWith('0')) {
      return trimmed.substring(0, 4);
    }
    return trimmed;
  }

  /// pagination_key 付きレスポンスをすべて結合して返す
  Future<List<Map<String, dynamic>>> _fetchAllData(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    final results = <Map<String, dynamic>>[];
    final params = Map<String, String>.from(queryParameters);

    while (true) {
      final uri = Uri.parse('$_baseUrl$path').replace(
        queryParameters: params.isEmpty ? null : params,
      );
      final response = await _client.get(uri, headers: _headers());

      if (response is! Map) {
        break;
      }

      final data = response['data'];
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            results.add(item);
          } else if (item is Map) {
            results.add(Map<String, dynamic>.from(item));
          }
        }
      }

      final paginationKey = response['pagination_key']?.toString();
      if (paginationKey == null || paginationKey.isEmpty) {
        break;
      }
      params['pagination_key'] = paginationKey;
    }

    return results;
  }

  static String _formatDateParam(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  /// 銘柄一覧の取得（/v2/equities/master）
  Future<List<StockMaster>> fetchStockList({String? code}) async {
    final params = <String, String>{};
    if (code != null && code.isNotEmpty) {
      params['code'] = normalizeCode(code);
    }

    final rows = await _fetchAllData('/equities/master', queryParameters: params);
    return rows.map(StockMaster.fromJson).toList();
  }

  /// 株価四本値の取得（/v2/equities/bars/daily）
  Future<List<DailyStockPrice>> fetchDailyPrices({
    required String code,
    String? from,
    String? to,
  }) async {
    final normalized = normalizeCode(code);
    final params = <String, String>{'code': normalized};

    if (from != null && from.isNotEmpty) {
      params['from'] = from;
    } else {
      final fromDate = DateTime.now().subtract(const Duration(days: 120));
      params['from'] = _formatDateParam(fromDate);
    }

    if (to != null && to.isNotEmpty) {
      params['to'] = to;
    }

    final rows = await _fetchAllData('/equities/bars/daily', queryParameters: params);
    final prices = rows.map(DailyStockPrice.fromJson).toList();
    prices.sort((a, b) => a.date.compareTo(b.date));
    return prices;
  }

  /// 財務情報サマリーの取得（/v2/fins/summary）
  Future<List<FinancialSummary>> fetchFinancialStatements({
    required String code,
  }) async {
    final normalized = normalizeCode(code);
    final rows = await _fetchAllData(
      '/fins/summary',
      queryParameters: {'code': normalized},
    );
    final summaries = rows.map(FinancialSummary.fromJson).toList();
    summaries.sort((a, b) => a.periodEnd.compareTo(b.periodEnd));
    return summaries;
  }
}
