/// API通信およびデータ処理に関する例外クラス定義
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// 認証エラー (APIキー未設定、期限切れ、不正など)
class ApiAuthException extends ApiException {
  ApiAuthException([super.message = '認証に失敗しました。APIキーを確認してください。', super.statusCode]);
}

/// レート制限エラー (429 Too Many Requests など)
class ApiRateLimitException extends ApiException {
  ApiRateLimitException([super.message = 'APIの利用制限に達しました。時間をおいて再試行してください。', super.statusCode]);
}

/// ネットワーク・接続エラー
class ApiNetworkException extends ApiException {
  ApiNetworkException([super.message = 'ネットワーク接続エラーが発生しました。通信環境を確認してください。']);
}

/// データ未検出・対象外エラー (404 Not Found など)
class ApiNotFoundException extends ApiException {
  ApiNotFoundException([super.message = '対象のデータが見つかりませんでした。', super.statusCode]);
}

/// レスポンス解析エラー (JSONパース失敗等)
class ApiDataParseException extends ApiException {
  ApiDataParseException([super.message = 'データの解析に失敗しました。']);
}

/// サーバーエラー (500等)
class ApiServerException extends ApiException {
  ApiServerException([super.message = 'サーバーエラーが発生しました。', super.statusCode]);
}
