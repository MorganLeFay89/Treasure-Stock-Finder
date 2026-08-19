/// 銘柄ドメインモデル
class Stock {
  final String stockCode;
  final String stockName;
  final String market;
  final String industry;
  final double? revenueGrowthRate;
  final double? operatingProfitGrowthRate;
  final double? profitMargin;
  final double? forecastPER;
  final double? pbr;
  final double? forecastDividendYield;
  final double? roe;
  final double? roa;
  final double? equityRatio;
  final int? marketCap;
  final double? aiScore;
  final String? note; // ETF等の注記メッセージ

  const Stock({
    required this.stockCode,
    required this.stockName,
    required this.market,
    required this.industry,
    this.revenueGrowthRate,
    this.operatingProfitGrowthRate,
    this.profitMargin,
    this.forecastPER,
    this.pbr,
    this.forecastDividendYield,
    this.roe,
    this.roa,
    this.equityRatio,
    this.marketCap,
    this.aiScore,
    this.note,
  });

  /// 表示用4桁コード（5桁で末尾が0の場合は4桁に変換）
  String get displayCode =>
      (stockCode.length == 5 && stockCode.endsWith('0')) ? stockCode.substring(0, 4) : stockCode;

  /// ETF / ETN / 投資信託かどうかを判定
  bool get isEtf =>
      market.contains('ETF') ||
      industry.contains('ETF') ||
      industry.contains('投信') ||
      industry.contains('その他') && stockName.contains('ETF') ||
      (note != null && note!.contains('ETF'));

  Stock copyWith({
    String? stockCode,
    String? stockName,
    String? market,
    String? industry,
    double? revenueGrowthRate,
    double? operatingProfitGrowthRate,
    double? profitMargin,
    double? forecastPER,
    double? pbr,
    double? forecastDividendYield,
    double? roe,
    double? roa,
    double? equityRatio,
    int? marketCap,
    double? aiScore,
    String? note,
  }) {
    return Stock(
      stockCode: stockCode ?? this.stockCode,
      stockName: stockName ?? this.stockName,
      market: market ?? this.market,
      industry: industry ?? this.industry,
      revenueGrowthRate: revenueGrowthRate ?? this.revenueGrowthRate,
      operatingProfitGrowthRate: operatingProfitGrowthRate ?? this.operatingProfitGrowthRate,
      profitMargin: profitMargin ?? this.profitMargin,
      forecastPER: forecastPER ?? this.forecastPER,
      pbr: pbr ?? this.pbr,
      forecastDividendYield: forecastDividendYield ?? this.forecastDividendYield,
      roe: roe ?? this.roe,
      roa: roa ?? this.roa,
      equityRatio: equityRatio ?? this.equityRatio,
      marketCap: marketCap ?? this.marketCap,
      aiScore: aiScore ?? this.aiScore,
      note: note ?? this.note,
    );
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      stockCode: json['stockCode']?.toString() ?? '',
      stockName: json['stockName']?.toString() ?? '',
      market: json['market']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      revenueGrowthRate: _toDouble(json['revenueGrowthRate']),
      operatingProfitGrowthRate: _toDouble(json['operatingProfitGrowthRate']),
      profitMargin: _toDouble(json['profitMargin']),
      forecastPER: _toDouble(json['forecastPER']),
      pbr: _toDouble(json['pbr']),
      forecastDividendYield: _toDouble(json['forecastDividendYield']),
      roe: _toDouble(json['roe']),
      roa: _toDouble(json['roa']),
      equityRatio: _toDouble(json['equityRatio']),
      marketCap: _toInt(json['marketCap']),
      aiScore: _toDouble(json['aiScore']),
      note: json['note']?.toString(),
    );
  }

  static double? _toDouble(dynamic val) {
    if (val == null || val == '' || val == '-') return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  static int? _toInt(dynamic val) {
    if (val == null || val == '' || val == '-') return null;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'stockCode': stockCode,
      'stockName': stockName,
      'market': market,
      'industry': industry,
      'revenueGrowthRate': revenueGrowthRate,
      'operatingProfitGrowthRate': operatingProfitGrowthRate,
      'profitMargin': profitMargin,
      'forecastPER': forecastPER,
      'pbr': pbr,
      'forecastDividendYield': forecastDividendYield,
      'roe': roe,
      'roa': roa,
      'equityRatio': equityRatio,
      'marketCap': marketCap,
      'aiScore': aiScore,
      'note': note,
    };
  }
}
