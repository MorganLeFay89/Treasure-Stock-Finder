import 'package:finance/features/stock_search/domain/stock_search_condition.dart';

/// 検索履歴アイテムモデル
class SearchHistoryItem {
  final String id;
  final DateTime searchDateTime;
  final StockSearchCondition condition;
  final int resultCount;
  final String displayName;

  const SearchHistoryItem({
    required this.id,
    required this.searchDateTime,
    required this.condition,
    required this.resultCount,
    required this.displayName,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['id']?.toString() ?? '',
      searchDateTime: DateTime.tryParse(json['searchDateTime']?.toString() ?? '') ?? DateTime.now(),
      condition: StockSearchCondition.fromJson(json['condition'] as Map<String, dynamic>),
      resultCount: (json['resultCount'] as num?)?.toInt() ?? 0,
      displayName: json['displayName']?.toString() ?? '検索条件',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'searchDateTime': searchDateTime.toIso8601String(),
      'condition': condition.toJson(),
      'resultCount': resultCount,
      'displayName': displayName,
    };
  }
}
