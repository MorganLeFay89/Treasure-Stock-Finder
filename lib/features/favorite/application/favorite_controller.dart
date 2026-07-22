import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/favorite/data/favorite_repository.dart';
import 'package:finance/features/stock_search/data/stock_repository.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/stock_search/domain/stock_search_condition.dart';

final favoriteRepositoryProvider = Provider((ref) => FavoriteRepository());

/// お気に入り銘柄コードのリストを管理するプロバイダ
final favoriteCodesProvider = AsyncNotifierProvider<FavoriteCodesNotifier, List<String>>(() {
  return FavoriteCodesNotifier();
});

class FavoriteCodesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final repo = ref.read(favoriteRepositoryProvider);
    return repo.getFavoriteCodes();
  }

  Future<void> toggleFavorite(String code) async {
    final repo = ref.read(favoriteRepositoryProvider);
    final current = state.value ?? [];
    final isFavorite = current.contains(code);

    if (isFavorite) {
      await repo.removeFavorite(code);
      state = AsyncData(current.where((c) => c != code).toList());
    } else {
      await repo.addFavorite(code);
      state = AsyncData([...current, code]);
    }
  }
}

/// お気に入りに登録された全銘柄のStockオブジェクトを取得するプロバイダ
final favoriteStocksProvider = FutureProvider<List<Stock>>((ref) async {
  final favoriteCodes = ref.watch(favoriteCodesProvider).value ?? [];
  final stockRepo = ref.watch(stockRepositoryProvider);
  
  // モックリポジトリの全銘柄を取得し、お気に入りコードでフィルタリング
  final allStocks = await stockRepo.searchStocks(const StockSearchCondition(market: '全市場')); // Note: 実際はリポジトリにgetStocksByCodes()等のメソッドを実装するのがベターですが、モックなので全件取得からフィルタします。
  
  return allStocks.where((stock) => favoriteCodes.contains(stock.stockCode)).toList();
});
