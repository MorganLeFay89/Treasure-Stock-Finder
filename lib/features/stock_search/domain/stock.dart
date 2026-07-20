import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock.freezed.dart';
part 'stock.g.dart';

@freezed
class Stock with _$Stock {
  const factory Stock({
    required String stockCode,
    required String stockName,
    required String market,
    required String industry,
    required double revenueGrowthRate,
    required double operatingProfitGrowthRate,
    required double profitMargin,
    required double forecastPER,
    required double pbr,
    required double forecastDividendYield,
    required double roe,
    required double roa,
    required double equityRatio,
    required int marketCap,
    double? aiScore,
  }) = _Stock;

  factory Stock.fromJson(Map<String, dynamic> json) => _$StockFromJson(json);
}
