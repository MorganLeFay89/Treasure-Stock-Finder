import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 環境変数から安全にAPIキーを取得するヘルパークラス。
/// .env_secrets/.env ファイルに記載されたキーを読み取ります。
class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env_secrets/.env');
  }

  /// Gemini API キー
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  /// 株価・財務データ API キー (旧互換用)
  static String get stockApiKey =>
      dotenv.env['STOCK_API_KEY'] ?? '';

  /// J-Quants API キー
  static String get jquantsApiKey =>
      dotenv.env['JQUANTS_API_KEY'] ?? '';

  /// EDINET API キー
  static String get edinetApiKey =>
      dotenv.env['EDINET_API_KEY'] ?? '';

  /// APIキーが設定済みかどうかを確認
  static bool get isGeminiApiKeySet =>
      geminiApiKey.isNotEmpty &&
      !geminiApiKey.contains('ここにあなたの') &&
      !geminiApiKey.contains('your_');

  static bool get isStockApiKeySet =>
      stockApiKey.isNotEmpty &&
      !stockApiKey.contains('ここにあなたの') &&
      !stockApiKey.contains('your_');

  static bool get isJquantsApiKeySet =>
      jquantsApiKey.isNotEmpty &&
      !jquantsApiKey.contains('ここにあなたの') &&
      !jquantsApiKey.contains('your_');

  static bool get isEdinetApiKeySet =>
      edinetApiKey.isNotEmpty &&
      !edinetApiKey.contains('ここにあなたの') &&
      !edinetApiKey.contains('your_');
}
