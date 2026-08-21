import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_search/domain/stock.dart';
import 'package:finance/features/stock_search/domain/stock_search_condition.dart';
import 'package:finance/features/stock_data/data/jquants_stock_repository.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return JQuantsStockRepository();
});

abstract class StockRepository {
  Future<List<Stock>> searchStocks(StockSearchCondition condition);
}

class MockStockRepository implements StockRepository {
  @override
  Future<List<Stock>> searchStocks(StockSearchCondition condition) async {
    // 擬似的なネットワーク遅延
    await Future.delayed(const Duration(milliseconds: 800));

    final mockStocks = [
      const Stock(
        stockCode: "7203",
        stockName: "トヨタ自動車",
        market: "東証プライム",
        industry: "輸送用機器",
        revenueGrowthRate: 12.5,
        operatingProfitGrowthRate: 18.3,
        profitMargin: 9.8,
        forecastPER: 11.2,
        pbr: 1.1,
        psr: 0.95,
        peg: 0.85,
        forecastDividendYield: 2.8,
        roe: 10.5,
        roa: 4.2,
        equityRatio: 38.0,
        marketCap: 45000000000000,
        aiScore: 82.0,
      ),
      const Stock(
        stockCode: "9984",
        stockName: "ソフトバンクグループ",
        market: "東証プライム",
        industry: "情報・通信業",
        revenueGrowthRate: 15.2,
        operatingProfitGrowthRate: 10.1,
        profitMargin: 12.0,
        forecastPER: 14.5,
        pbr: 1.5,
        psr: 1.80,
        peg: 1.25,
        forecastDividendYield: 1.2,
        roe: 8.5,
        roa: 3.1,
        equityRatio: 25.0,
        marketCap: 12000000000000,
        aiScore: 75.5,
      ),
      const Stock(
        stockCode: "6861",
        stockName: "キーエンス",
        market: "東証プライム",
        industry: "電気機器",
        revenueGrowthRate: 20.1,
        operatingProfitGrowthRate: 25.4,
        profitMargin: 54.3,
        forecastPER: 45.2,
        pbr: 6.8,
        psr: 16.5,
        peg: 2.10,
        forecastDividendYield: 0.8,
        roe: 15.2,
        roa: 12.1,
        equityRatio: 94.5,
        marketCap: 16000000000000,
        aiScore: 91.0,
      ),
      const Stock(
        stockCode: "1234",
        stockName: "サンプル株式会社",
        market: "東証グロース",
        industry: "情報通信",
        revenueGrowthRate: 25.4,
        operatingProfitGrowthRate: 40.1,
        profitMargin: 18.5,
        forecastPER: 16.2,
        pbr: 1.4,
        psr: 2.10,
        peg: 0.75,
        forecastDividendYield: 3.1,
        roe: 22.0,
        roa: 10.5,
        equityRatio: 65.0,
        marketCap: 50000000000,
        aiScore: 86.0,
      ),
    ];

    // モックでの簡易フィルタリング
    return mockStocks.where((stock) {
      if (condition.revenueGrowthRateMin != null && (stock.revenueGrowthRate == null || stock.revenueGrowthRate! < condition.revenueGrowthRateMin!)) return false;
      if (condition.revenueGrowthRateMax != null && (stock.revenueGrowthRate == null || stock.revenueGrowthRate! > condition.revenueGrowthRateMax!)) return false;
      if (condition.operatingProfitGrowthRateMin != null && (stock.operatingProfitGrowthRate == null || stock.operatingProfitGrowthRate! < condition.operatingProfitGrowthRateMin!)) return false;
      if (condition.operatingProfitGrowthRateMax != null && (stock.operatingProfitGrowthRate == null || stock.operatingProfitGrowthRate! > condition.operatingProfitGrowthRateMax!)) return false;
      if (condition.profitMarginMin != null && (stock.profitMargin == null || stock.profitMargin! < condition.profitMarginMin!)) return false;
      if (condition.profitMarginMax != null && (stock.profitMargin == null || stock.profitMargin! > condition.profitMarginMax!)) return false;
      if (condition.forecastPERMin != null && (stock.forecastPER == null || stock.forecastPER! < condition.forecastPERMin!)) return false;
      if (condition.forecastPERMax != null && (stock.forecastPER == null || stock.forecastPER! > condition.forecastPERMax!)) return false;
      if (condition.pbrMin != null && (stock.pbr == null || stock.pbr! < condition.pbrMin!)) return false;
      if (condition.pbrMax != null && (stock.pbr == null || stock.pbr! > condition.pbrMax!)) return false;
      if (condition.psrMin != null && (stock.psr == null || stock.psr! < condition.psrMin!)) return false;
      if (condition.psrMax != null && (stock.psr == null || stock.psr! > condition.psrMax!)) return false;
      if (condition.pegMin != null && (stock.peg == null || stock.peg! < condition.pegMin!)) return false;
      if (condition.pegMax != null && (stock.peg == null || stock.peg! > condition.pegMax!)) return false;
      if (condition.forecastDividendYieldMin != null && (stock.forecastDividendYield == null || stock.forecastDividendYield! < condition.forecastDividendYieldMin!)) return false;
      if (condition.forecastDividendYieldMax != null && (stock.forecastDividendYield == null || stock.forecastDividendYield! > condition.forecastDividendYieldMax!)) return false;
      if (condition.equityRatioMin != null && (stock.equityRatio == null || stock.equityRatio! < condition.equityRatioMin!)) return false;
      if (condition.equityRatioMax != null && (stock.equityRatio == null || stock.equityRatio! > condition.equityRatioMax!)) return false;
      if (condition.market != null && condition.market != "全市場" && stock.market != condition.market) return false;
      
      return true;
    }).toList();
  }
}
