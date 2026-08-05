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
                  stock.stockCode,
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
            const Divider(height: 32),

            // 財務・バリュエーション指標
            const Text(
              '財務・バリュエーション指標',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('売上高成長率', '${stock.revenueGrowthRate}%'),
            _buildInfoRow('営業利益成長率', '${stock.operatingProfitGrowthRate}%'),
            _buildInfoRow('利益率', '${stock.profitMargin}%'),
            _buildInfoRow('予想PER', stock.forecastPER > 0 ? '${stock.forecastPER}倍' : (valuation?.per != null ? '${valuation!.per}倍' : '--')),
            _buildInfoRow('PBR', stock.pbr > 0 ? '${stock.pbr}倍' : (valuation?.pbr != null ? '${valuation!.pbr}倍' : '--')),
            _buildInfoRow('PSR (株価売上高倍率)', valuation?.psr != null ? '${valuation!.psr}倍' : '--'),
            _buildInfoRow('PEG レシオ (実績ベース)', valuation?.peg != null ? '${valuation!.peg}倍' : '--'),
            _buildInfoRow('予想配当利回り', stock.forecastDividendYield > 0 ? '${stock.forecastDividendYield}%' : (valuation?.dividendYield != null ? '${valuation!.dividendYield}%' : '--')),
            _buildInfoRow('ROE', '${stock.roe}%'),
            _buildInfoRow('ROA', '${stock.roa}%'),
            _buildInfoRow('自己資本比率', '${stock.equityRatio}%'),

            const Divider(height: 32),

            // EDINET 開示書類一覧
            const Text(
              'EDINET 開示書類 (直近)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            edinetDocsAsync.when(
              data: (docs) {
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('※直近の開示書類が見つからないか、EDINET APIキーが未設定です。', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 5 ? 5 : docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.description_outlined, color: Colors.blue),
                      title: Text('${doc.docTypeName} (${doc.submitDateTime.toString().substring(0, 10)})'),
                      subtitle: Text(doc.docDescription, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  },
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
              error: (err, stack) => Text('EDINET取得エラー: $err', style: const TextStyle(color: Colors.grey)),
            ),

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
