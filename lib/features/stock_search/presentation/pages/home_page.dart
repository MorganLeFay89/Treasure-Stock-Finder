import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finance/shared/widgets/range_input_widget.dart';
import 'package:finance/features/stock_search/application/stock_search_controller.dart';
import 'package:finance/features/search_history/application/search_history_controller.dart';
import 'package:finance/features/stock_data/application/jquants_sync_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = ref.watch(stockSearchConditionProvider);
    final syncStatus = ref.watch(jquantsSyncServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treasure Stock Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'APIキー設定・ガイド',
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '検索履歴',
            onPressed: () => context.push('/search_history'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'お気に入り',
            onPressed: () => context.push('/favorites'),
          ),
        ],
      ),
      body: Column(
        children: [
          // バックグラウンド同期ステータスバー
          if (syncStatus.isRunning || syncStatus.cachedCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: syncStatus.isRateLimited ? Colors.orange.shade100 : Colors.blue.shade50,
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: syncStatus.isRateLimited ? Colors.orange.shade800 : Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      syncStatus.isRateLimited
                          ? '⏱️ APIリミット待機中 (保存済み: ${syncStatus.cachedCount}銘柄)'
                          : '🔄 バックグラウンド自動同期中: ${syncStatus.cachedCount}銘柄保存完了 (${syncStatus.currentSyncingCode ?? ""} ${syncStatus.currentSyncingName ?? ""})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: syncStatus.isRateLimited ? Colors.orange.shade900 : Colors.blue.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('お宝株を探す', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  RangeInputWidget(
                    label: '売上高成長率',
                    unit: '%',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(revenueGrowthRateMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(revenueGrowthRateMax: double.tryParse(val)));
                    },
                  ),
                  RangeInputWidget(
                    label: '営業利益成長率',
                    unit: '%',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(operatingProfitGrowthRateMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(operatingProfitGrowthRateMax: double.tryParse(val)));
                    },
                  ),
                  RangeInputWidget(
                    label: '利益率',
                    unit: '%',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(profitMarginMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(profitMarginMax: double.tryParse(val)));
                    },
                  ),
                  RangeInputWidget(
                    label: '予想PER',
                    unit: '倍',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(forecastPERMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(forecastPERMax: double.tryParse(val)));
                    },
                  ),
                  RangeInputWidget(
                    label: 'PBR',
                    unit: '倍',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(pbrMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(pbrMax: double.tryParse(val)));
                    },
                  ),
                  RangeInputWidget(
                    label: 'PSR (株価売上高倍率)',
                    unit: '倍',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(psrMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(psrMax: double.tryParse(val)));
                    },
                  ),
                  RangeInputWidget(
                    label: 'PEG レシオ (実績ベース)',
                    unit: '倍',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(pegMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(pegMax: double.tryParse(val)));
                    },
                  ),
                  RangeInputWidget(
                    label: '予想配当利回り',
                    unit: '%',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(forecastDividendYieldMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(forecastDividendYieldMax: double.tryParse(val)));
                    },
                  ),
                  RangeInputWidget(
                    label: '自己資本比率',
                    unit: '%',
                    onChangedMin: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(equityRatioMin: double.tryParse(val)));
                    },
                    onChangedMax: (val) {
                      ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(equityRatioMax: double.tryParse(val)));
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('市場', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: condition.market,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '全市場', child: Text('全市場')),
                      DropdownMenuItem(value: '東証プライム', child: Text('東証プライム')),
                      DropdownMenuItem(value: '東証スタンダード', child: Text('東証スタンダード')),
                      DropdownMenuItem(value: '東証グロース', child: Text('東証グロース')),
                      DropdownMenuItem(value: '米国株', child: Text('米国株')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(stockSearchConditionProvider.notifier).update((state) => state.copyWith(market: val));
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () async {
                      // 検索実行時に履歴を追加し、即時ローカル検索結果画面へ遷移
                      final searchCondition = ref.read(stockSearchConditionProvider);
                      final searchResults = await ref.read(searchResultsProvider.future);
                      ref.read(searchHistoryControllerProvider.notifier).addHistory(
                            condition: searchCondition,
                            resultCount: searchResults.length,
                          );

                      if (context.mounted) {
                        context.push('/search_results');
                      }
                    },
                    child: const Text('検索する (ローカル高速スクリーニング)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '免責事項\n本アプリは投資判断を支援する情報提供ツールです。\n特定の金融商品の売買を推奨するものではありません。\n投資判断はご自身の責任で行ってください。',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
