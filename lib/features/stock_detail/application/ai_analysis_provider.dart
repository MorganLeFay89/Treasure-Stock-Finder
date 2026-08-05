import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_detail/data/ai_analysis_service.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/stock_data/domain/valuation_metrics.dart';
import 'package:finance/features/stock_data/domain/edinet_document.dart';

final aiAnalysisServiceProvider = Provider((ref) => AiAnalysisService());

/// AI分析リクエスト用パラメータ
class AiAnalysisParams {
  final Stock stock;
  final ValuationMetrics? valuationMetrics;
  final List<EdinetDocument>? edinetDocs;

  const AiAnalysisParams({
    required this.stock,
    this.valuationMetrics,
    this.edinetDocs,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiAnalysisParams &&
          runtimeType == other.runtimeType &&
          stock.stockCode == other.stock.stockCode;

  @override
  int get hashCode => stock.stockCode.hashCode;
}

/// 特定の銘柄に対する強化版AI分析結果を取得するFutureProvider
final enhancedAiAnalysisProvider =
    FutureProvider.family<String, AiAnalysisParams>((ref, params) async {
  final service = ref.watch(aiAnalysisServiceProvider);
  return service.analyzeStockEnhanced(
    stock: params.stock,
    valuationMetrics: params.valuationMetrics,
    edinetDocs: params.edinetDocs,
  );
});

/// 互換用プロバイダ
final aiAnalysisProvider =
    FutureProvider.family<String, Stock>((ref, stock) async {
  final service = ref.watch(aiAnalysisServiceProvider);
  return service.analyzeStock(stock);
});
