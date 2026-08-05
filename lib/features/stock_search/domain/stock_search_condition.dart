import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_search_condition.freezed.dart';
part 'stock_search_condition.g.dart';

@freezed
class StockSearchCondition with _$StockSearchCondition {
  const factory StockSearchCondition({
    String? market,
    String? industry,
    double? revenueGrowthRateMin,
    double? revenueGrowthRateMax,
    double? operatingProfitGrowthRateMin,
    double? operatingProfitGrowthRateMax,
    double? profitMarginMin,
    double? profitMarginMax,
    double? forecastPERMin,
    double? forecastPERMax,
    double? pbrMin,
    double? pbrMax,
    double? psrMin,
    double? psrMax,
    double? pegMin,
    double? pegMax,
    double? forecastDividendYieldMin,
    double? forecastDividendYieldMax,
  }) = _StockSearchCondition;

  factory StockSearchCondition.fromJson(Map<String, dynamic> json) => _$StockSearchConditionFromJson(json);
}
