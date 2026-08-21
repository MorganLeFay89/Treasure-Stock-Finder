import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_data/data/jquants_api_client.dart';
import 'package:finance/features/stock_data/data/jquants_stock_repository.dart';
import 'package:finance/features/stock_data/domain/valuation_metrics.dart';
import 'package:finance/features/stock_data/domain/financial_summary.dart';
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

    // 最新レコードでEPS/BPSが"-"などで欠損している場合、より古いレコードから補完
    final effectiveFinancials = FinancialSummary.findLatestEffectiveFinancials(financials);
    final effectiveDividend = FinancialSummary.findLatestEffectiveDividend(financials);

    // EPS・BPSが欠損している最新レコードを補完したコピーを作成
    final patchedFinancial = latestFinancial == null
        ? null
        : (latestFinancial.eps != null && latestFinancial.bps != null)
            ? latestFinancial
            : FinancialSummary(
                code: latestFinancial.code,
                periodEnd: latestFinancial.periodEnd,
                revenue: latestFinancial.revenue,
                operatingProfit: latestFinancial.operatingProfit,
                ordinaryProfit: latestFinancial.ordinaryProfit,
                netIncome: latestFinancial.netIncome,
                eps: latestFinancial.eps ?? effectiveFinancials.eps,
                bps: latestFinancial.bps ?? effectiveFinancials.bps,
                dividendPerShare: latestFinancial.dividendPerShare,
                issuedShares: latestFinancial.issuedShares,
                equity: latestFinancial.equity,
                totalAssets: latestFinancial.totalAssets,
                equityRatio: latestFinancial.equityRatio,
              );

    return ValuationCalculator.calculateMetrics(
      code: code,
      latestPrice: latestPrice,
      latestFinancial: patchedFinancial,
      previousFinancial: previousFinancial,
      effectiveDividend: effectiveDividend,
    );
  } catch (_) {
    return null;
  }
});
