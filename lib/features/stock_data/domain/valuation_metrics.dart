/// バリュエーション指標モデル (PER, PBR, PSR, PEG, 配当利回り, 時価総額)
class ValuationMetrics {
  final String code;
  final double? per;
  final double? pbr;
  final double? psr;
  final double? peg;
  final double? dividendYield;
  final double? marketCap;

  const ValuationMetrics({
    required this.code,
    this.per,
    this.pbr,
    this.psr,
    this.peg,
    this.dividendYield,
    this.marketCap,
  });

  factory ValuationMetrics.fromJson(Map<String, dynamic> json) {
    return ValuationMetrics(
      code: json['code']?.toString() ?? '',
      per: _toDouble(json['per']),
      pbr: _toDouble(json['pbr']),
      psr: _toDouble(json['psr']),
      peg: _toDouble(json['peg']),
      dividendYield: _toDouble(json['dividendYield']),
      marketCap: _toDouble(json['marketCap']),
    );
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'per': per,
      'pbr': pbr,
      'psr': psr,
      'peg': peg,
      'dividendYield': dividendYield,
      'marketCap': marketCap,
    };
  }
}
