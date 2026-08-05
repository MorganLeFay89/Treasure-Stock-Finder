import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finance/core/api_error.dart';

/// 共通の HTTP クライアント。
/// ログのマスキング、エラーレスポンスの統一的なハンドリングを担当します。
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// GET リクエストを実行
  Future<dynamic> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client.get(uri, headers: headers);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiNetworkException('通信エラーが発生しました: $e');
    }
  }

  /// POST リクエストを実行
  Future<dynamic> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: body is Map || body is List ? jsonEncode(body) : body,
      );
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiNetworkException('通信エラーが発生しました: $e');
    }
  }

  /// HTTP レスポンスステータスコードに応じた処理
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiDataParseException('JSONの解析に失敗しました');
      }
    }

    switch (statusCode) {
      case 401:
      case 403:
        throw ApiAuthException('認証エラーが発生しました。APIキーを確認してください。', statusCode);
      case 404:
        throw ApiNotFoundException('リクエストされたリソースが見つかりません。', statusCode);
      case 429:
        throw ApiRateLimitException('APIリクエストの上限に達しました。時間をおいて再試行してください。', statusCode);
      default:
        if (statusCode >= 500) {
          throw ApiServerException('サーバー側でエラーが発生しました ($statusCode)', statusCode);
        }
        throw ApiException('HTTPエラー ($statusCode): ${response.reasonPhrase}', statusCode);
    }
  }
}
