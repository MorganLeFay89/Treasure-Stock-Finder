import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finance/core/api_error.dart';
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
        error: (error, stack) {
          final isRateLimit = error is ApiRateLimitException;
          final isAuthError = error is ApiAuthException;

          return Column(
            children: [
              // 画面最上部の固定警告バナー
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isRateLimit ? Colors.orange.shade800 : Colors.red.shade800,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isRateLimit ? Icons.speed : Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isRateLimit
                            ? '⚠️ API利用上限（レート制限）に達しました'
                            : isAuthError
                                ? '⚠️ API認証エラーが発生しました'
                                : '⚠️ 検索エラーが発生しました',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.invalidate(searchResultsProvider);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('再試行', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 中央〜下部の詳細説明カード
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      color: isRateLimit ? Colors.orange.shade50 : Colors.red.shade50,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isRateLimit
                                  ? 'J-Quants APIのアクセス回数制限（HTTP 429）を超過しています。\n\n【対処方法】\n短時間に多数のリクエストが行われたため、データ取得が一時制限されています。\n数分〜数十分ほど時間をおいてから上部の「再試行」ボタンをタップしてください。'
                                  : error.toString(),
                              style: const TextStyle(fontSize: 14, height: 1.6),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.settings),
                              label: const Text('APIキー設定・ステータスを確認'),
                              onPressed: () {
                                context.push('/settings');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
