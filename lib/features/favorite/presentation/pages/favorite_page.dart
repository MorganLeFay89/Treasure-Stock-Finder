import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finance/features/favorite/application/favorite_controller.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteStocksAsync = ref.watch(favoriteStocksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り銘柄'),
      ),
      body: favoriteStocksAsync.when(
        data: (stocks) {
          if (stocks.isEmpty) {
            return const Center(
              child: Text('お気に入りに登録された銘柄はありません。'),
            );
          }
          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return ListTile(
                title: Text(stock.stockName),
                subtitle: Text('${stock.stockCode} | ${stock.market}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/stock_detail', extra: stock);
                },
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
