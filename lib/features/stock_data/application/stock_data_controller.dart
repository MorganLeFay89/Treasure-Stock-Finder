import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_data/data/jquants_api_client.dart';
import 'package:finance/features/stock_data/data/jquants_stock_repository.dart';
import 'package:finance/features/stock_data/domain/valuation_metrics.dart';
import 'package:finance/features/stock_data/application/valuation_calculator.dart';

final jquantsApiClientProvider = Provider((ref) => JQuantsApiClient());

final jquantsStockRepositoryProvider = Provider((ref) {
  return JQuantsStockRepository();
});

/// 銘柄ごとの詳細株価・財務・バリュエーション指標を取得するプロバイダ
final stockValuationMetricsProvider = FutureProvider.family<ValuationMetrics?, String>((ref, code) async {
  final client = ref.watch(jquantsApiClientProvider);
  try {
    final prices = await client.fetchDailyPrices(code: code);
    final financials = await client.fetchFinancialStatements(code: code);

    final latestPrice = prices.isNotEmpty ? prices.last : null;
    final latestFinancial = financials.isNotEmpty ? financials.last : null;
    final previousFinancial = financials.length >= 2 ? financials[financials.length - 2] : null;

    return ValuationCalculator.calculateMetrics(
      code: code,
      latestPrice: latestPrice,
      latestFinancial: latestFinancial,
      previousFinancial: previousFinancial,
    );
  } catch (_) {
    return null;
  }
});
