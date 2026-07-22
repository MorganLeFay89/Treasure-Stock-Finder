import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_detail/data/ai_analysis_service.dart';
import 'package:finance/features/stock_search/domain/stock.dart';

final aiAnalysisServiceProvider = Provider((ref) => AiAnalysisService());

/// 特定の銘柄に対するAI分析結果を取得するFutureProvider
final aiAnalysisProvider = FutureProvider.family<String, Stock>((ref, stock) async {
  final service = ref.watch(aiAnalysisServiceProvider);
  return service.analyzeStock(stock);
});
