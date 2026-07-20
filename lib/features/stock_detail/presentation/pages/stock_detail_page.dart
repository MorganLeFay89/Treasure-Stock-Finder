import 'package:flutter/material.dart';
import 'package:finance/features/stock_search/domain/stock.dart';

class StockDetailPage extends StatelessWidget {
  final Stock stock;

  const StockDetailPage({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stock.stockName),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('お気に入りに追加しました (Phase 2で実装)')),
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
              'AIコメント (モック)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'この銘柄は売上高成長率と営業利益成長率がともに高く、事業拡大の勢いが確認できます。一方で、PERは業界平均と比較してやや低く、成長性に対して割安に評価されている可能性があります。（※Phase 2でGemini APIに置き換わります）',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'リスク要因 (モック)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '利益率の変動が大きいため、今後の決算推移を確認する必要があります。',
                style: TextStyle(fontSize: 16),
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
