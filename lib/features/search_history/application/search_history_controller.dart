import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/search_history/data/search_history_repository.dart';
import 'package:finance/features/search_history/domain/search_history_item.dart';
import 'package:finance/features/stock_search/domain/stock_search_condition.dart';

final searchHistoryRepositoryProvider = Provider((ref) => SearchHistoryRepository());

/// 検索履歴一覧の状態を管理するAsyncNotifierProvider
final searchHistoryControllerProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<SearchHistoryItem>>(() {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends AsyncNotifier<List<SearchHistoryItem>> {
  @override
  Future<List<SearchHistoryItem>> build() async {
    final repo = ref.read(searchHistoryRepositoryProvider);
    return repo.getHistoryItems();
  }

  /// 検索実行時に履歴を追加
  Future<void> addHistory({
    required StockSearchCondition condition,
    required int resultCount,
  }) async {
    final repo = ref.read(searchHistoryRepositoryProvider);
    final now = DateTime.now();

    // 条件要約テキストの生成
    final summaryParts = <String>[];
    if (condition.market != null && condition.market != '全市場') summaryParts.add(condition.market!);
    if (condition.forecastPERMax != null) summaryParts.add('PER<= ${condition.forecastPERMax}倍');
    if (condition.pbrMax != null) summaryParts.add('PBR<= ${condition.pbrMax}倍');
    if (condition.revenueGrowthRateMin != null) summaryParts.add('売上成長率>= ${condition.revenueGrowthRateMin}%');
    if (condition.forecastDividendYieldMin != null) summaryParts.add('配当利回り>= ${condition.forecastDividendYieldMin}%');

    final displayName = summaryParts.isNotEmpty ? summaryParts.join(' / ') : '全銘柄検索';

    final item = SearchHistoryItem(
      id: '${now.millisecondsSinceEpoch}',
      searchDateTime: now,
      condition: condition,
      resultCount: resultCount,
      displayName: displayName,
    );

    await repo.addHistoryItem(item);
    state = AsyncData(await repo.getHistoryItems());
  }

  /// 特定の履歴を削除
  Future<void> deleteHistory(String id) async {
    final repo = ref.read(searchHistoryRepositoryProvider);
    await repo.deleteHistoryItem(id);
    state = AsyncData(await repo.getHistoryItems());
  }

  /// 全履歴を削除
  Future<void> clearAll() async {
    final repo = ref.read(searchHistoryRepositoryProvider);
    await repo.clearAllHistory();
    state = const AsyncData([]);
  }
}
