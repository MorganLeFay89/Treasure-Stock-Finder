import 'package:finance/features/stock_data/domain/daily_stock_price.dart';
import 'package:finance/features/stock_data/domain/financial_summary.dart';
import 'package:finance/features/stock_data/domain/valuation_metrics.dart';

/// 仕様書第4章に基づくバリュエーション指標・成長率の計算ロジック
class ValuationCalculator {
  /// PER (株価収益率) = 株価 / EPS
  static double? calculatePER({double? price, double? eps}) {
    if (price == null || eps == null || eps <= 0) return null;
    return double.parse((price / eps).toStringAsFixed(2));
  }

  /// PBR (株価純資産倍率) = 株価 / BPS
  static double? calculatePBR({double? price, double? bps}) {
    if (price == null || bps == null || bps <= 0) return null;
    return double.parse((price / bps).toStringAsFixed(2));
  }

  /// 時価総額 = 株価 * 発行済株式数
  static double? calculateMarketCap({double? price, int? issuedShares}) {
    if (price == null || issuedShares == null || issuedShares <= 0) return null;
    return price * issuedShares;
  }

  /// PSR (株価売上高倍率) = 時価総額 / 売上高 (原則通期直近売上高ベース)
  static double? calculatePSR({double? marketCap, double? revenue}) {
    if (marketCap == null || revenue == null || revenue <= 0) return null;
    return double.parse((marketCap / revenue).toStringAsFixed(2));
  }

  /// PEG レシオ = PER / EPS成長率 (過去実績ベース簡易計算)
  static double? calculatePEG({double? per, double? epsGrowthRate}) {
    if (per == null || epsGrowthRate == null || epsGrowthRate <= 0) return null;
    return double.parse((per / epsGrowthRate).toStringAsFixed(2));
  }

  /// 配当利回り(%) = 1株配当 / 株価 * 100
  static double? calculateDividendYield({double? price, double? dividendPerShare}) {
    if (price == null || dividendPerShare == null || price <= 0) return null;
    return double.parse(((dividendPerShare / price) * 100).toStringAsFixed(2));
  }

  /// 売上高成長率(%) = (直近期売上高 / 前期売上高 - 1) * 100
  static double? calculateRevenueGrowthRate({double? currentRevenue, double? previousRevenue}) {
    if (currentRevenue == null || previousRevenue == null || previousRevenue <= 0) return null;
    return double.parse((((currentRevenue / previousRevenue) - 1) * 100).toStringAsFixed(2));
  }

  /// 営業利益成長率(%) = (直近営業利益 / 前期営業利益 - 1) * 100
  static double? calculateOperatingProfitGrowthRate({double? currentOp, double? previousOp}) {
    if (currentOp == null || previousOp == null || previousOp <= 0) return null;
    return double.parse((((currentOp / previousOp) - 1) * 100).toStringAsFixed(2));
  }

  /// 売上高営業利益率(%) = (営業利益 / 売上高) * 100
  static double? calculateProfitMargin({double? operatingProfit, double? revenue}) {
    if (operatingProfit == null || revenue == null || revenue <= 0) return null;
    return double.parse(((operatingProfit / revenue) * 100).toStringAsFixed(2));
  }

  /// ROE(%) (概算: EPS / BPS * 100)
  static double? calculateROE({double? eps, double? bps}) {
    if (eps == null || bps == null || bps <= 0) return null;
    return double.parse(((eps / bps) * 100).toStringAsFixed(2));
  }

  /// 自己資本比率(%) = 自己資本 / 総資産 * 100
  static double? calculateEquityRatio({
    double? directEquityRatio,
    double? equity,
    double? totalAssets,
  }) {
    if (directEquityRatio != null && directEquityRatio > 0) {
      return double.parse(directEquityRatio.toStringAsFixed(2));
    }
    if (equity == null || totalAssets == null || totalAssets <= 0) return null;
    return double.parse(((equity / totalAssets) * 100).toStringAsFixed(2));
  }

  /// EPS成長率(%) = (直近EPS / 前期EPS - 1) * 100
  static double? calculateEpsGrowthRate({double? currentEps, double? previousEps}) {
    if (currentEps == null || previousEps == null || previousEps <= 0) return null;
    return double.parse((((currentEps / previousEps) - 1) * 100).toStringAsFixed(2));
  }

  /// 日次株価・財務サマリー等から包括的な ValuationMetrics を一括計算
  static ValuationMetrics calculateMetrics({
    required String code,
    DailyStockPrice? latestPrice,
    FinancialSummary? latestFinancial,
    FinancialSummary? previousFinancial,
  }) {
    final price = latestPrice?.close;
    final eps = latestFinancial?.eps;
    final bps = latestFinancial?.bps;
    final revenue = latestFinancial?.revenue;
    final dividend = latestFinancial?.dividendPerShare;
    final shares = latestFinancial?.issuedShares;

    final per = calculatePER(price: price, eps: eps);
    final pbr = calculatePBR(price: price, bps: bps);
    final marketCap = calculateMarketCap(price: price, issuedShares: shares);
    final psr = calculatePSR(marketCap: marketCap, revenue: revenue);

    final epsGrowth = calculateEpsGrowthRate(
      currentEps: eps,
      previousEps: previousFinancial?.eps,
    );
    final peg = calculatePEG(per: per, epsGrowthRate: epsGrowth);
    final dividendYield = calculateDividendYield(price: price, dividendPerShare: dividend);

    return ValuationMetrics(
      code: code,
      per: per,
      pbr: pbr,
      psr: psr,
      peg: peg,
      dividendYield: dividendYield,
      marketCap: marketCap,
    );
  }
}
