import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_search/domain/stock_search_condition.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/stock_search/data/stock_repository.dart';

final stockSearchConditionProvider = StateProvider<StockSearchCondition>((ref) {
  return const StockSearchCondition(market: '全市場');
});

final searchResultsProvider = FutureProvider<List<Stock>>((ref) async {
  final condition = ref.watch(stockSearchConditionProvider);
  final repository = ref.watch(stockRepositoryProvider);
  return repository.searchStocks(condition);
});
