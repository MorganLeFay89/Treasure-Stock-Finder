// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_search_condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockSearchConditionImpl _$$StockSearchConditionImplFromJson(
        Map<String, dynamic> json) =>
    _$StockSearchConditionImpl(
      market: json['market'] as String?,
      industry: json['industry'] as String?,
      revenueGrowthRateMin: (json['revenueGrowthRateMin'] as num?)?.toDouble(),
      revenueGrowthRateMax: (json['revenueGrowthRateMax'] as num?)?.toDouble(),
      operatingProfitGrowthRateMin:
          (json['operatingProfitGrowthRateMin'] as num?)?.toDouble(),
      operatingProfitGrowthRateMax:
          (json['operatingProfitGrowthRateMax'] as num?)?.toDouble(),
      profitMarginMin: (json['profitMarginMin'] as num?)?.toDouble(),
      profitMarginMax: (json['profitMarginMax'] as num?)?.toDouble(),
      forecastPERMin: (json['forecastPERMin'] as num?)?.toDouble(),
      forecastPERMax: (json['forecastPERMax'] as num?)?.toDouble(),
      pbrMin: (json['pbrMin'] as num?)?.toDouble(),
      pbrMax: (json['pbrMax'] as num?)?.toDouble(),
      psrMin: (json['psrMin'] as num?)?.toDouble(),
      psrMax: (json['psrMax'] as num?)?.toDouble(),
      pegMin: (json['pegMin'] as num?)?.toDouble(),
      pegMax: (json['pegMax'] as num?)?.toDouble(),
      forecastDividendYieldMin:
          (json['forecastDividendYieldMin'] as num?)?.toDouble(),
      forecastDividendYieldMax:
          (json['forecastDividendYieldMax'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$StockSearchConditionImplToJson(
        _$StockSearchConditionImpl instance) =>
    <String, dynamic>{
      'market': instance.market,
      'industry': instance.industry,
      'revenueGrowthRateMin': instance.revenueGrowthRateMin,
      'revenueGrowthRateMax': instance.revenueGrowthRateMax,
      'operatingProfitGrowthRateMin': instance.operatingProfitGrowthRateMin,
      'operatingProfitGrowthRateMax': instance.operatingProfitGrowthRateMax,
      'profitMarginMin': instance.profitMarginMin,
      'profitMarginMax': instance.profitMarginMax,
      'forecastPERMin': instance.forecastPERMin,
      'forecastPERMax': instance.forecastPERMax,
      'pbrMin': instance.pbrMin,
      'pbrMax': instance.pbrMax,
      'psrMin': instance.psrMin,
      'psrMax': instance.psrMax,
      'pegMin': instance.pegMin,
      'pegMax': instance.pegMax,
      'forecastDividendYieldMin': instance.forecastDividendYieldMin,
      'forecastDividendYieldMax': instance.forecastDividendYieldMax,
    };
