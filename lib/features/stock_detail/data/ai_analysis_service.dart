import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/stock_data/domain/valuation_metrics.dart';
import 'package:finance/features/stock_data/domain/edinet_document.dart';

class AiAnalysisService {
  /// J-Quantsの実財務データ、計算されたバリュエーション指標、EDINET開示情報を組み合わせたAI分析
  Future<String> analyzeStockEnhanced({
    required Stock stock,
    ValuationMetrics? valuationMetrics,
    List<EdinetDocument>? edinetDocs,
  }) async {
    if (!EnvConfig.isGeminiApiKeySet) {
      return 'エラー: Gemini APIキーが設定されていません。\n.env_secrets/.env ファイルに「GEMINI_API_KEY」を設定してください。';
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: EnvConfig.geminiApiKey,
    );

    // EDINET開示情報の要約テキスト作成
    String disclosureSummary = '開示書類情報なし';
    if (edinetDocs != null && edinetDocs.isNotEmpty) {
      final latestDoc = edinetDocs.first;
      disclosureSummary = '直近開示: ${latestDoc.docTypeName} (${latestDoc.submitDateTime.toString().substring(0, 10)}) - ${latestDoc.docDescription}';
    }

    final perStr = valuationMetrics?.per != null ? '${valuationMetrics!.per}倍' : '${stock.forecastPER}倍';
    final pbrStr = valuationMetrics?.pbr != null ? '${valuationMetrics!.pbr}倍' : '${stock.pbr}倍';
    final psrStr = valuationMetrics?.psr != null ? '${valuationMetrics!.psr}倍' : '算出不可/データ不足';
    final pegStr = valuationMetrics?.peg != null ? '${valuationMetrics!.peg}倍 (簡易過去実績ベース)' : '算出不可/データ不足';
    final dividendStr = valuationMetrics?.dividendYield != null ? '${valuationMetrics!.dividendYield}%' : '${stock.forecastDividendYield}%';

    final prompt = '''
あなたは個人投資家向けの財務分析アシスタントです。
以下の企業データをもとに、投資判断を断定せず、情報提供として多角的に分析してください。

【対象銘柄】
銘柄コード: ${stock.stockCode}
企業名: ${stock.stockName}
市場: ${stock.market}
業種: ${stock.industry}

【財務・バリュエーション指標】
PER: $perStr
PBR: $pbrStr
PSR: $psrStr
PEG: $pegStr
売上高成長率: ${stock.revenueGrowthRate}%
営業利益成長率: ${stock.operatingProfitGrowthRate}%
利益率: ${stock.profitMargin}%
配当利回り: $dividendStr
ROE: ${stock.roe}%
ROA: ${stock.roa}%
自己資本比率: ${stock.equityRatio}%

【EDINET開示情報】
$disclosureSummary

【出力形式（以下の番号順に、わかりやすくプレーンテキストまたはMarkdownで出力してください）】
1. 総合コメント
2. 割安性（PER, PBR, PSR, PEGの評価）
3. 成長性（売上・利益成長率の評価）
4. 財務安全性（自己資本比率・ROE等の評価）
5. リスク要因（懸念される点や注意が必要な点）
6. 注意点
7. 免責事項（本分析は情報提供を目的としており、投資の推奨や勧誘ではありません）
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? '分析結果を生成できませんでした。';
    } catch (e) {
      return 'AIによる分析中にエラーが発生しました: $e';
    }
  }

  /// 旧互換用メソッド
  Future<String> analyzeStock(Stock stock) async {
    return analyzeStockEnhanced(stock: stock);
  }
}
