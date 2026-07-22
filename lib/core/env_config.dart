import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 環境変数から安全にAPIキーを取得するヘルパークラス。
/// .envファイルに記載されたキーを読み取ります。
class EnvConfig {
  /// Gemini API キー
  static Future<void> init() async {
    await dotenv.load(fileName: '.env_secrets/.env');
  }

  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  /// 株価・財務データ API キー
  static String get stockApiKey =>
      dotenv.env['STOCK_API_KEY'] ?? '';

  /// APIキーが設定済みかどうかを確認
  static bool get isGeminiApiKeySet =>
      geminiApiKey.isNotEmpty &&
      geminiApiKey != 'ここにあなたのGemini_APIキーを貼り付けてください';

  static bool get isStockApiKeySet =>
      stockApiKey.isNotEmpty &&
      stockApiKey != 'ここにあなたの株価APIキーを貼り付けてください';
}
