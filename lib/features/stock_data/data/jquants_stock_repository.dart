import 'package:flutter/foundation.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_data/data/stock_local_cache_repository.dart';
import 'package:finance/features/stock_search/data/stock_repository.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/stock_search/domain/stock_search_condition.dart';

/// ローカルに同期蓄積された銘柄データに対する超高速スクリーニングリポジトリ
class JQuantsStockRepository implements StockRepository {
  final StockLocalCacheRepository _cacheRepo;
  final MockStockRepository _fallbackRepository;

  JQuantsStockRepository({
    StockLocalCacheRepository? cacheRepo,
    MockStockRepository? fallbackRepository,
  })  : _cacheRepo = cacheRepo ?? StockLocalCacheRepository(),
        _fallbackRepository = fallbackRepository ?? MockStockRepository();

  @override
  Future<List<Stock>> searchStocks(StockSearchCondition condition) async {
    // 1. ローカルキャッシュから全保存済み銘柄を取得
    final cachedStocks = await _cacheRepo.getCachedStocks();

    if (kDebugMode) {
      print('[JQuantsStockRepository] ローカルキャッシュ検索開始 (保存済み銘柄数: ${cachedStocks.length})');
    }

    // キャッシュが空でAPIキー未設定の場合、モックデータへ安全にフォールバック
    if (cachedStocks.isEmpty && !EnvConfig.isJquantsApiKeySet) {
      return _fallbackRepository.searchStocks(condition);
    }

    // キャッシュがまだ0件（初回起動直後）でAPI設定済みの場合はモックで仮表示
    if (cachedStocks.isEmpty) {
      return _fallbackRepository.searchStocks(condition);
    }

    // 2. ローカルデータに対するスクリーニングフィルタリング
    final filteredResults = cachedStocks.where((stock) {
      if (condition.market != null && condition.market != '全市場') {
        if (!stock.market.contains(condition.market!) && !condition.market!.contains(stock.market)) {
          return false;
        }
      }
      if (condition.revenueGrowthRateMin != null && (stock.revenueGrowthRate == null || stock.revenueGrowthRate! < condition.revenueGrowthRateMin!)) {
        return false;
      }
      if (condition.revenueGrowthRateMax != null && (stock.revenueGrowthRate == null || stock.revenueGrowthRate! > condition.revenueGrowthRateMax!)) {
        return false;
      }
      if (condition.operatingProfitGrowthRateMin != null && (stock.operatingProfitGrowthRate == null || stock.operatingProfitGrowthRate! < condition.operatingProfitGrowthRateMin!)) {
        return false;
      }
      if (condition.operatingProfitGrowthRateMax != null && (stock.operatingProfitGrowthRate == null || stock.operatingProfitGrowthRate! > condition.operatingProfitGrowthRateMax!)) {
        return false;
      }
      if (condition.profitMarginMin != null && (stock.profitMargin == null || stock.profitMargin! < condition.profitMarginMin!)) {
        return false;
      }
      if (condition.profitMarginMax != null && (stock.profitMargin == null || stock.profitMargin! > condition.profitMarginMax!)) {
        return false;
      }
      if (condition.forecastPERMin != null && (stock.forecastPER == null || stock.forecastPER! < condition.forecastPERMin!)) {
        return false;
      }
      if (condition.forecastPERMax != null && (stock.forecastPER == null || stock.forecastPER! > condition.forecastPERMax!)) {
        return false;
      }
      if (condition.pbrMin != null && (stock.pbr == null || stock.pbr! < condition.pbrMin!)) {
        return false;
      }
      if (condition.pbrMax != null && (stock.pbr == null || stock.pbr! > condition.pbrMax!)) {
        return false;
      }
      if (condition.psrMin != null && (stock.psr == null || stock.psr! < condition.psrMin!)) {
        return false;
      }
      if (condition.psrMax != null && (stock.psr == null || stock.psr! > condition.psrMax!)) {
        return false;
      }
      if (condition.pegMin != null && (stock.peg == null || stock.peg! < condition.pegMin!)) {
        return false;
      }
      if (condition.pegMax != null && (stock.peg == null || stock.peg! > condition.pegMax!)) {
        return false;
      }
      if (condition.forecastDividendYieldMin != null && (stock.forecastDividendYield == null || stock.forecastDividendYield! < condition.forecastDividendYieldMin!)) {
        return false;
      }
      if (condition.forecastDividendYieldMax != null && (stock.forecastDividendYield == null || stock.forecastDividendYield! > condition.forecastDividendYieldMax!)) {
        return false;
      }
      if (condition.equityRatioMin != null && (stock.equityRatio == null || stock.equityRatio! < condition.equityRatioMin!)) {
        return false;
      }
      if (condition.equityRatioMax != null && (stock.equityRatio == null || stock.equityRatio! > condition.equityRatioMax!)) {
        return false;
      }
      return true;
    }).toList();

    if (kDebugMode) {
      print('[JQuantsStockRepository] スクリーニングヒット件数: ${filteredResults.length} / ${cachedStocks.length}');
    }

    return filteredResults;
  }
}
