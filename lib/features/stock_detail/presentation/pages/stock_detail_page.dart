import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/favorite/application/favorite_controller.dart';
import 'package:finance/features/stock_detail/application/ai_analysis_provider.dart';

class StockDetailPage extends ConsumerWidget {
  final Stock stock;

  const StockDetailPage({super.key, required this.stock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteCodesAsync = ref.watch(favoriteCodesProvider);
    final favoriteCodes = favoriteCodesAsync.value ?? [];
    final isFavorite = favoriteCodes.contains(stock.stockCode);

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
            _buildInfoRow('売上高成長率', '${stock.revenueGrowthRate}%'),
            _buildInfoRow('営業利益成長率', '${stock.operatingProfitGrowthRate}%'),
            _buildInfoRow('利益率', '${stock.profitMargin}%'),
            _buildInfoRow('予想PER', '${stock.forecastPER}倍'),
            _buildInfoRow('PBR', '${stock.pbr}倍'),
            _buildInfoRow('予想配当利回り', '${stock.forecastDividendYield}%'),
            _buildInfoRow('ROE', '${stock.roe}%'),
            _buildInfoRow('ROA', '${stock.roa}%'),
            _buildInfoRow('自己資本比率', '${stock.equityRatio}%'),
            const Divider(height: 32),
            const Text(
              'Gemini AI 分析',
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
              child: ref.watch(aiAnalysisProvider(stock)).when(
                    data: (analysis) => Text(
                      analysis,
                      style: const TextStyle(fontSize: 16),
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
