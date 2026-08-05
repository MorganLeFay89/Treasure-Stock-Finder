import 'package:finance/core/api_client.dart';
import 'package:finance/core/api_error.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_data/domain/daily_stock_price.dart';
import 'package:finance/features/stock_data/domain/financial_summary.dart';
import 'package:finance/features/stock_data/domain/stock_master.dart';

/// J-Quants API 通信用クライアント
class JQuantsApiClient {
  static const String _baseUrl = 'https://api.jquants.com/v1';
  final ApiClient _client;
  String? _idToken;

  JQuantsApiClient({ApiClient? client}) : _client = client ?? ApiClient();

  /// IDトークン取得（未取得または期限切れ時に呼び出し）
  Future<String> _getIdToken() async {
    if (_idToken != null && _idToken!.isNotEmpty) {
      return _idToken!;
    }

    if (!EnvConfig.isJquantsApiKeySet) {
      throw ApiAuthException('J-Quants APIキーが設定されていません。.env_secrets/.env を確認してください。');
    }

    final refreshToken = EnvConfig.jquantsApiKey;
    final uri = Uri.parse('$_baseUrl/token/auth/refresh?refreshtoken=$refreshToken');

    final response = await _client.post(uri);
    if (response is Map && response.containsKey('idToken')) {
      _idToken = response['idToken'].toString();
      return _idToken!;
    }
    throw ApiAuthException('J-Quants IDトークンの取得に失敗しました。');
  }

  /// 共通ヘッダー（IDトークン付き）
  Future<Map<String, String>> _headers() async {
    final token = await _getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// 銘柄一覧の取得
  Future<List<StockMaster>> fetchStockList({String? code}) async {
    var uriString = '$_baseUrl/listed/info';
    if (code != null && code.isNotEmpty) {
      uriString += '?code=$code';
    }
    final uri = Uri.parse(uriString);
    final headers = await _headers();

    final response = await _client.get(uri, headers: headers);
    if (response is Map && response.containsKey('info')) {
      final list = response['info'] as List;
      return list.map((json) => StockMaster.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// 株価四本値の取得
  Future<List<DailyStockPrice>> fetchDailyPrices({
    required String code,
    String? from,
    String? to,
  }) async {
    var uriString = '$_baseUrl/prices/daily_quotes?code=$code';
    if (from != null) uriString += '&from=$from';
    if (to != null) uriString += '&to=$to';

    final uri = Uri.parse(uriString);
    final headers = await _headers();

    final response = await _client.get(uri, headers: headers);
    if (response is Map && response.containsKey('daily_quotes')) {
      final list = response['daily_quotes'] as List;
      return list.map((json) => DailyStockPrice.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// 財務情報サマリーの取得
  Future<List<FinancialSummary>> fetchFinancialStatements({
    required String code,
  }) async {
    final uri = Uri.parse('$_baseUrl/fins/statements?code=$code');
    final headers = await _headers();

    final response = await _client.get(uri, headers: headers);
    if (response is Map && response.containsKey('statements')) {
      final list = response['statements'] as List;
      return list.map((json) => FinancialSummary.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
