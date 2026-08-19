import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/favorite/application/favorite_controller.dart';
import 'package:finance/features/stock_detail/application/ai_analysis_provider.dart';
import 'package:finance/features/stock_data/application/stock_data_controller.dart';
import 'package:finance/features/stock_data/data/edinet_repository.dart';

class StockDetailPage extends ConsumerWidget {
  final Stock stock;

  const StockDetailPage({super.key, required this.stock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteCodesAsync = ref.watch(favoriteCodesProvider);
    final favoriteCodes = favoriteCodesAsync.value ?? [];
    final isFavorite = favoriteCodes.contains(stock.stockCode);

    final valuationAsync = ref.watch(stockValuationMetricsProvider(stock.stockCode));
    final edinetDocsAsync = ref.watch(edinetDocumentsProvider(stock.stockCode));

    final valuation = valuationAsync.value;
    final edinetDocs = edinetDocsAsync.value;

    final aiParams = AiAnalysisParams(
      stock: stock,
      valuationMetrics: valuation,
      edinetDocs: edinetDocs,
    );

    final perVal = stock.forecastPER ?? valuation?.per;
    final pbrVal = stock.pbr ?? valuation?.pbr;
    final psrVal = valuation?.psr;
    final pegVal = valuation?.peg;
    final yieldVal = stock.forecastDividendYield ?? valuation?.dividendYield;
    final revGrowthVal = stock.revenueGrowthRate;
    final opGrowthVal = stock.operatingProfitGrowthRate;
    final marginVal = stock.profitMargin;
    final roeVal = stock.roe;
    final equityRatioVal = stock.equityRatio;

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.stockName),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(favoriteCodesProvider.notifier).toggleFavorite(stock.stockCode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFavorite ? 'お気に入りから削除しました' : 'お気に入りに追加しました'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stock.displayCode,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  stock.market,
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              stock.stockName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(stock.industry, style: const TextStyle(fontSize: 16)),

            if (stock.isEtf || stock.note != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.purple.shade800, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stock.note ?? '※ 本銘柄はETF/投資信託のため、企業の決算財務諸表（売上高・利益成長率・ROE等）は公表されていません。',
                        style: TextStyle(fontSize: 13, color: Colors.purple.shade900, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 32),

            // 財務・バリュエーション指標
            const Text(
              '財務・バリュエーション指標',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('売上高成長率', revGrowthVal != null ? '$revGrowthVal%' : '--'),
            _buildInfoRow('営業利益成長率', opGrowthVal != null ? '$opGrowthVal%' : '--'),
            _buildInfoRow('利益率', marginVal != null ? '$marginVal%' : '--'),
            _buildInfoRow('予想PER', perVal != null && perVal > 0 ? '$perVal倍' : '--'),
            _buildInfoRow('PBR', pbrVal != null && pbrVal > 0 ? '$pbrVal倍' : '--'),
            _buildInfoRow('PSR (株価売上高倍率)', psrVal != null && psrVal > 0 ? '$psrVal倍' : '--'),
            _buildInfoRow('PEG レシオ (実績ベース)', pegVal != null && pegVal > 0 ? '$pegVal倍' : '--'),
            _buildInfoRow('予想配当利回り', yieldVal != null && yieldVal > 0 ? '$yieldVal%' : '--'),
            _buildInfoRow('ROE', roeVal != null ? '$roeVal%' : '--'),
            _buildInfoRow('自己資本比率', equityRatioVal != null && equityRatioVal > 0 ? '$equityRatioVal%' : '--'),

            const Divider(height: 32),

            // Gemini AI 分析
            const Text(
              'Gemini AI 分析 (統合版)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ref.watch(enhancedAiAnalysisProvider(aiParams)).when(
                    data: (analysis) => SelectableText(
                      analysis,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('J-Quants・EDINETデータを解析中...'),
                          ],
                        ),
                      ),
                    ),
                    error: (err, stack) => Text(
                      'エラーが発生しました: $err',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
