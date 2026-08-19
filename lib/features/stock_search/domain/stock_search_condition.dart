/// 銘柄検索・スクリーニング条件モデル
class StockSearchCondition {
  final String? market;
  final String? industry;
  final double? revenueGrowthRateMin;
  final double? revenueGrowthRateMax;
  final double? operatingProfitGrowthRateMin;
  final double? operatingProfitGrowthRateMax;
  final double? profitMarginMin;
  final double? profitMarginMax;
  final double? forecastPERMin;
  final double? forecastPERMax;
  final double? pbrMin;
  final double? pbrMax;
  final double? psrMin;
  final double? psrMax;
  final double? pegMin;
  final double? pegMax;
  final double? forecastDividendYieldMin;
  final double? forecastDividendYieldMax;
  final double? equityRatioMin;
  final double? equityRatioMax;

  const StockSearchCondition({
    this.market,
    this.industry,
    this.revenueGrowthRateMin,
    this.revenueGrowthRateMax,
    this.operatingProfitGrowthRateMin,
    this.operatingProfitGrowthRateMax,
    this.profitMarginMin,
    this.profitMarginMax,
    this.forecastPERMin,
    this.forecastPERMax,
    this.pbrMin,
    this.pbrMax,
    this.psrMin,
    this.psrMax,
    this.pegMin,
    this.pegMax,
    this.forecastDividendYieldMin,
    this.forecastDividendYieldMax,
    this.equityRatioMin,
    this.equityRatioMax,
  });

  StockSearchCondition copyWith({
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
    double? equityRatioMin,
    double? equityRatioMax,
  }) {
    return StockSearchCondition(
      market: market ?? this.market,
      industry: industry ?? this.industry,
      revenueGrowthRateMin: revenueGrowthRateMin ?? this.revenueGrowthRateMin,
      revenueGrowthRateMax: revenueGrowthRateMax ?? this.revenueGrowthRateMax,
      operatingProfitGrowthRateMin: operatingProfitGrowthRateMin ?? this.operatingProfitGrowthRateMin,
      operatingProfitGrowthRateMax: operatingProfitGrowthRateMax ?? this.operatingProfitGrowthRateMax,
      profitMarginMin: profitMarginMin ?? this.profitMarginMin,
      profitMarginMax: profitMarginMax ?? this.profitMarginMax,
      forecastPERMin: forecastPERMin ?? this.forecastPERMin,
      forecastPERMax: forecastPERMax ?? this.forecastPERMax,
      pbrMin: pbrMin ?? this.pbrMin,
      pbrMax: pbrMax ?? this.pbrMax,
      psrMin: psrMin ?? this.psrMin,
      psrMax: psrMax ?? this.psrMax,
      pegMin: pegMin ?? this.pegMin,
      pegMax: pegMax ?? this.pegMax,
      forecastDividendYieldMin: forecastDividendYieldMin ?? this.forecastDividendYieldMin,
      forecastDividendYieldMax: forecastDividendYieldMax ?? this.forecastDividendYieldMax,
      equityRatioMin: equityRatioMin ?? this.equityRatioMin,
      equityRatioMax: equityRatioMax ?? this.equityRatioMax,
    );
  }

  factory StockSearchCondition.fromJson(Map<String, dynamic> json) {
    return StockSearchCondition(
      market: json['market']?.toString(),
      industry: json['industry']?.toString(),
      revenueGrowthRateMin: _toDouble(json['revenueGrowthRateMin']),
      revenueGrowthRateMax: _toDouble(json['revenueGrowthRateMax']),
      operatingProfitGrowthRateMin: _toDouble(json['operatingProfitGrowthRateMin']),
      operatingProfitGrowthRateMax: _toDouble(json['operatingProfitGrowthRateMax']),
      profitMarginMin: _toDouble(json['profitMarginMin']),
      profitMarginMax: _toDouble(json['profitMarginMax']),
      forecastPERMin: _toDouble(json['forecastPERMin']),
      forecastPERMax: _toDouble(json['forecastPERMax']),
      pbrMin: _toDouble(json['pbrMin']),
      pbrMax: _toDouble(json['pbrMax']),
      psrMin: _toDouble(json['psrMin']),
      psrMax: _toDouble(json['psrMax']),
      pegMin: _toDouble(json['pegMin']),
      pegMax: _toDouble(json['pegMax']),
      forecastDividendYieldMin: _toDouble(json['forecastDividendYieldMin']),
      forecastDividendYieldMax: _toDouble(json['forecastDividendYieldMax']),
      equityRatioMin: _toDouble(json['equityRatioMin']),
      equityRatioMax: _toDouble(json['equityRatioMax']),
    );
  }

  static double? _toDouble(dynamic val) {
    if (val == null || val == '' || val == '-') return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'market': market,
      'industry': industry,
      'revenueGrowthRateMin': revenueGrowthRateMin,
      'revenueGrowthRateMax': revenueGrowthRateMax,
      'operatingProfitGrowthRateMin': operatingProfitGrowthRateMin,
      'operatingProfitGrowthRateMax': operatingProfitGrowthRateMax,
      'profitMarginMin': profitMarginMin,
      'profitMarginMax': profitMarginMax,
      'forecastPERMin': forecastPERMin,
      'forecastPERMax': forecastPERMax,
      'pbrMin': pbrMin,
      'pbrMax': pbrMax,
      'psrMin': psrMin,
      'psrMax': psrMax,
      'pegMin': pegMin,
      'pegMax': pegMax,
      'forecastDividendYieldMin': forecastDividendYieldMin,
      'forecastDividendYieldMax': forecastDividendYieldMax,
      'equityRatioMin': equityRatioMin,
      'equityRatioMax': equityRatioMax,
    };
  }
}
