/// 財務サマリーモデル (J-Quants / EDINET共通データ構造)
class FinancialSummary {
  final String code;
  final DateTime periodEnd;
  final double? revenue;             // 売上高
  final double? operatingProfit;    // 営業利益
  final double? ordinaryProfit;     // 経常利益
  final double? netIncome;          // 当期純利益
  final double? eps;                // 1株当たり当期純利益
  final double? bps;                // 1株当たり純資産
  final double? dividendPerShare;   // 1株当たり配当金
  final int? issuedShares;          // 発行済株式数
  final double? equity;             // 自己資本（純資産）
  final double? totalAssets;        // 総資産
  final double? equityRatio;        // 自己資本比率 (%)

  const FinancialSummary({
    required this.code,
    required this.periodEnd,
    this.revenue,
    this.operatingProfit,
    this.ordinaryProfit,
    this.netIncome,
    this.eps,
    this.bps,
    this.dividendPerShare,
    this.issuedShares,
    this.equity,
    this.totalAssets,
    this.equityRatio,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['CurPerEn'] != null && json['CurPerEn'].toString().isNotEmpty) {
      parsedDate = DateTime.tryParse(json['CurPerEn'].toString()) ?? DateTime.now();
    } else if (json['DiscDate'] != null) {
      parsedDate = DateTime.tryParse(json['DiscDate'].toString()) ?? DateTime.now();
    } else if (json['DisclosedDate'] != null) {
      parsedDate = DateTime.tryParse(json['DisclosedDate'].toString()) ?? DateTime.now();
    } else if (json['periodEnd'] != null) {
      parsedDate = DateTime.tryParse(json['periodEnd'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawEquityRatio = _toDouble(
      json['EqCstR'] ??
          json['EquityToAssetRatio'] ??
          json['equityRatio'],
    );
    // 0.50 のように小数表現の場合はパーセント (50.0) に変換
    final normalizedEquityRatio = rawEquityRatio != null && rawEquityRatio > 0 && rawEquityRatio <= 1.0
        ? rawEquityRatio * 100.0
        : rawEquityRatio;

    return FinancialSummary(
      code: json['Code']?.toString() ?? json['LocalCode']?.toString() ?? json['code']?.toString() ?? '',
      periodEnd: parsedDate,
      revenue: _toDouble(json['Sales'] ?? json['NetSales'] ?? json['revenue']),
      operatingProfit: _toDouble(json['OP'] ?? json['OperatingProfit'] ?? json['operatingProfit']),
      ordinaryProfit: _toDouble(json['OdP'] ?? json['OrdinaryProfit'] ?? json['ordinaryProfit']),
      netIncome: _toDouble(json['NP'] ?? json['Profit'] ?? json['netIncome']),
      eps: _toDouble(json['EPS'] ?? json['EarningsPerShare'] ?? json['eps']),
      bps: _toDouble(json['BPS'] ?? json['BookValuePerShare'] ?? json['bps']),
      dividendPerShare: _toDouble(
        json['FDivAnn'] ??
            json['DivAnn'] ??
            json['ForecastDividendPerShareAnnual'] ??
            json['ResultDividendPerShareAnnual'] ??
            json['dividendPerShare'],
      ),
      issuedShares: _toInt(
        json['ShOutFY'] ??
            json['NumberOfIssuedAndOutstandingSharesAtTheEndOfFiscalYearIncludingTreasuryStock'] ??
            json['issuedShares'],
      ),
      equity: _toDouble(json['Eq'] ?? json['Equity'] ?? json['equity']),
      totalAssets: _toDouble(json['TA'] ?? json['TotalAssets'] ?? json['totalAssets']),
      equityRatio: normalizedEquityRatio,
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
      'code': code,
      'periodEnd': periodEnd.toIso8601String(),
      'revenue': revenue,
      'operatingProfit': operatingProfit,
      'ordinaryProfit': ordinaryProfit,
      'netIncome': netIncome,
      'eps': eps,
      'bps': bps,
      'dividendPerShare': dividendPerShare,
      'issuedShares': issuedShares,
      'equity': equity,
      'totalAssets': totalAssets,
      'equityRatio': equityRatio,
    };
  }
}
