import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finance/features/search_history/application/search_history_controller.dart';
import 'package:finance/features/stock_search/application/stock_search_controller.dart';

class SearchHistoryPage extends ConsumerWidget {
  const SearchHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(searchHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('検索履歴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'すべての履歴を削除',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('履歴の全削除'),
                  content: const Text('検索履歴をすべて削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('削除', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(searchHistoryControllerProvider.notifier).clearAll();
              }
            },
          ),
        ],
      ),
      body: historyAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('検索履歴はありません。'),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final dateStr =
                  '${item.searchDateTime.year}/${item.searchDateTime.month.toString().padLeft(2, '0')}/${item.searchDateTime.day.toString().padLeft(2, '0')} ${item.searchDateTime.hour.toString().padLeft(2, '0')}:${item.searchDateTime.minute.toString().padLeft(2, '0')}';

              return ListTile(
                title: Text(
                  item.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$dateStr | 該当: ${item.resultCount}件'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay, color: Colors.blue),
                      tooltip: 'この条件を再適用して検索',
                      onPressed: () {
                        // 検索条件を反映させて検索結果へ遷移
                        ref.read(stockSearchConditionProvider.notifier).state = item.condition;
                        context.push('/search_results');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      tooltip: '削除',
                      onPressed: () {
                        ref.read(searchHistoryControllerProvider.notifier).deleteHistory(item.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  ref.read(stockSearchConditionProvider.notifier).state = item.condition;
                  context.push('/search_results');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
      ),
    );
  }
}
