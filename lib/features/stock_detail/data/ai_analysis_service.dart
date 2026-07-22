import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_search/domain/stock.dart';

class AiAnalysisService {
  Future<String> analyzeStock(Stock stock) async {
    if (!EnvConfig.isGeminiApiKeySet) {
      return 'エラー: Gemini APIキーが設定されていません。\\n.envファイルに「GEMINI_API_KEY」を設定してください。';
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: EnvConfig.geminiApiKey,
    );

    final prompt = '''
以下の株式銘柄の財務指標を分析し、個人投資家向けにわかりやすく解説してください。
長すぎず、3〜4段落程度でまとめてください。

【対象銘柄】
- 銘柄名: ${stock.stockName} (${stock.stockCode})
- 市場: ${stock.market}
- 業種: ${stock.industry}

【財務指標】
- 売上高成長率: ${stock.revenueGrowthRate}%
- 営業利益成長率: ${stock.operatingProfitGrowthRate}%
- 利益率: ${stock.profitMargin}%
- 予想PER: ${stock.forecastPER}倍
- PBR: ${stock.pbr}倍
- 予想配当利回り: ${stock.forecastDividendYield}%
- ROE: ${stock.roe}%
- ROA: ${stock.roa}%
- 自己資本比率: ${stock.equityRatio}%

【出力フォーマット（Markdownを使用せずプレーンテキストで出力してください）】
・総合評価（ポジティブ/ニュートラル/ネガティブのいずれかと一言コメント）
・成長性と割安度の分析
・リスク要因（懸念される点）
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? '分析結果を生成できませんでした。';
    } catch (e) {
      return 'AIによる分析中にエラーが発生しました: $e';
    }
  }
}
