import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finance/features/stock_search/application/stock_search_controller.dart';
import 'package:finance/features/stock_data/application/stock_data_controller.dart';

class SearchResultsPage extends ConsumerWidget {
  const SearchResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('検索結果'),
      ),
      body: searchResultsAsync.when(
        data: (stocks) {
          if (stocks.isEmpty) {
            return const Center(child: Text('条件に合致する銘柄が見つかりませんでした。'));
          }
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              final valuationAsync = ref.watch(stockValuationMetricsProvider(stock.stockCode));
              final valuation = valuationAsync.value;

              final perText = stock.forecastPER > 0 ? '${stock.forecastPER}倍' : (valuation?.per != null ? '${valuation!.per}倍' : '--');
              final pbrText = stock.pbr > 0 ? '${stock.pbr}倍' : (valuation?.pbr != null ? '${valuation!.pbr}倍' : '--');
              final psrText = valuation?.psr != null ? '${valuation!.psr}倍' : '--';
              final pegText = valuation?.peg != null ? '${valuation!.peg}倍' : '--';
              final yieldText = stock.forecastDividendYield > 0 ? '${stock.forecastDividendYield}%' : (valuation?.dividendYield != null ? '${valuation!.dividendYield}%' : '--');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    context.push('/stock_detail', extra: stock);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${stock.stockCode} ${stock.stockName}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                stock.market,
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stock.industry,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Divider(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _buildMetricChip('PER', perText),
                            _buildMetricChip('PBR', pbrText),
                            _buildMetricChip('PSR', psrText),
                            _buildMetricChip('PEG', pegText, isSimplePeg: valuation?.peg != null),
                            _buildMetricChip('配当利回り', yieldText),
                            _buildMetricChip('売上成長率', '${stock.revenueGrowthRate}%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, {bool isSimplePeg = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        if (isSimplePeg) ...[
          const SizedBox(width: 2),
          const Tooltip(
            message: '過去実績ベースの簡易計算PEGです',
            child: Icon(Icons.info_outline, size: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}
