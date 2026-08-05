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
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['DisclosedDate'] != null) {
      parsedDate = DateTime.tryParse(json['DisclosedDate'].toString()) ?? DateTime.now();
    } else if (json['periodEnd'] != null) {
      parsedDate = DateTime.tryParse(json['periodEnd'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return FinancialSummary(
      code: json['LocalCode']?.toString() ?? json['code']?.toString() ?? '',
      periodEnd: parsedDate,
      revenue: _toDouble(json['NetSales'] ?? json['revenue']),
      operatingProfit: _toDouble(json['OperatingProfit'] ?? json['operatingProfit']),
      ordinaryProfit: _toDouble(json['OrdinaryProfit'] ?? json['ordinaryProfit']),
      netIncome: _toDouble(json['Profit'] ?? json['netIncome']),
      eps: _toDouble(json['EarningsPerShare'] ?? json['eps']),
      bps: _toDouble(json['BookValuePerShare'] ?? json['bps']),
      dividendPerShare: _toDouble(json['ForecastDividendPerShareAnnual'] ?? json['ResultDividendPerShareAnnual'] ?? json['dividendPerShare']),
      issuedShares: _toInt(json['NumberOfIssuedAndOutstandingSharesAtTheEndOfFiscalYearIncludingTreasuryStock'] ?? json['issuedShares']),
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
    };
  }
}
