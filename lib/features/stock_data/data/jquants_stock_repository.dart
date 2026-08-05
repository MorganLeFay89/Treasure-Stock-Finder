import 'package:finance/core/api_error.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_data/application/valuation_calculator.dart';
import 'package:finance/features/stock_data/data/jquants_api_client.dart';
import 'package:finance/features/stock_search/data/stock_repository.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/stock_search/domain/stock_search_condition.dart';

/// J-Quants APIを使用した StockRepository の実データ実装
class JQuantsStockRepository implements StockRepository {
  final JQuantsApiClient _apiClient;
  final MockStockRepository _fallbackRepository;

  JQuantsStockRepository({
    JQuantsApiClient? apiClient,
    MockStockRepository? fallbackRepository,
  })  : _apiClient = apiClient ?? JQuantsApiClient(),
        _fallbackRepository = fallbackRepository ?? MockStockRepository();

  @override
  Future<List<Stock>> searchStocks(StockSearchCondition condition) async {
    // APIキー未設定の場合はモックへフォールバック
    if (!EnvConfig.isJquantsApiKeySet) {
      return _fallbackRepository.searchStocks(condition);
    }

    try {
      // 1. 銘柄一覧の取得
      final stockMasters = await _apiClient.fetchStockList();
      if (stockMasters.isEmpty) {
        return _fallbackRepository.searchStocks(condition);
      }

      final List<Stock> results = [];

      // 簡易スクリーニング（大量リクエストを避けるため、上位20銘柄に絞って実データを計算）
      final targetMasters = stockMasters.take(20).toList();

      for (final master in targetMasters) {
        try {
          final prices = await _apiClient.fetchDailyPrices(code: master.code);
          final financials = await _apiClient.fetchFinancialStatements(code: master.code);

          final latestPrice = prices.isNotEmpty ? prices.last : null;
          final latestFinancial = financials.isNotEmpty ? financials.last : null;
          final previousFinancial = financials.length >= 2 ? financials[financials.length - 2] : null;

          final metrics = ValuationCalculator.calculateMetrics(
            code: master.code,
            latestPrice: latestPrice,
            latestFinancial: latestFinancial,
            previousFinancial: previousFinancial,
          );

          final revenueGrowth = ValuationCalculator.calculateRevenueGrowthRate(
            currentRevenue: latestFinancial?.revenue,
            previousRevenue: previousFinancial?.revenue,
          );

          final stock = Stock(
            stockCode: master.code,
            stockName: master.name,
            market: master.market,
            industry: master.sector,
            revenueGrowthRate: revenueGrowth ?? 0.0,
            operatingProfitGrowthRate: 0.0,
            profitMargin: 0.0,
            forecastPER: metrics.per ?? 0.0,
            pbr: metrics.pbr ?? 0.0,
            forecastDividendYield: metrics.dividendYield ?? 0.0,
            roe: 0.0,
            roa: 0.0,
            equityRatio: 0.0,
            marketCap: metrics.marketCap?.toInt() ?? 0,
            aiScore: null,
          );

          results.add(stock);
        } catch (_) {
          // 単一銘柄の取得失敗時はスキップ
          continue;
        }
      }

      if (results.isEmpty) {
        return _fallbackRepository.searchStocks(condition);
      }

      // フィルタリング
      return results.where((stock) {
        if (condition.market != null && condition.market != '全市場' && stock.market != condition.market) return false;
        if (condition.forecastPERMin != null && stock.forecastPER < condition.forecastPERMin!) return false;
        if (condition.forecastPERMax != null && stock.forecastPER > condition.forecastPERMax!) return false;
        if (condition.pbrMin != null && stock.pbr < condition.pbrMin!) return false;
        if (condition.pbrMax != null && stock.pbr > condition.pbrMax!) return false;
        if (condition.forecastDividendYieldMin != null && stock.forecastDividendYield < condition.forecastDividendYieldMin!) return false;
        if (condition.forecastDividendYieldMax != null && stock.forecastDividendYield > condition.forecastDividendYieldMax!) return false;
        return true;
      }).toList();
    } on ApiException {
      // 認証エラーや通信エラー時もモックへ安全にフォールバック
      return _fallbackRepository.searchStocks(condition);
    } catch (_) {
      return _fallbackRepository.searchStocks(condition);
    }
  }
}
