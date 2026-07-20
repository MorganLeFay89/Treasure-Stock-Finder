import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finance/features/stock_search/application/stock_search_controller.dart';

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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${stock.stockCode} ${stock.stockName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${stock.market} / ${stock.industry}'),
                      const SizedBox(height: 4),
                      Text('AIスコア: ${stock.aiScore ?? "N/A"}'),
                      Text('予想PER: ${stock.forecastPER}倍 / 配当: ${stock.forecastDividendYield}%'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/stock_detail', extra: stock);
                  },
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
}
