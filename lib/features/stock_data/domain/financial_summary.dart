/// 財務サマリーモデル (J-Quants / EDINET共通データ構造)
class FinancialSummary {
  final String code;
  final DateTime periodEnd;
  final double? revenue;             // 売上高
  final double? operatingProfit;    // 営業利益
  final double? ordinaryProfit;     // 経常利益
  final double? netIncome;          // 当期純利益
  final double? eps;                // 1株当たり当期純利益（予想 or 実績）
  final double? bps;                // 1株当たり純資産
  final double? dividendPerShare;   // 1株当たり予想/実績年間配当金
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

    final rawEquityRatio = _firstValidDouble(json, [
      'EqCstR', 'EquityToAssetRatio', 'equityRatio',
    ]);
    // 0.50 のように小数表現の場合はパーセント (50.0) に変換
    final normalizedEquityRatio = rawEquityRatio != null && rawEquityRatio > 0 && rawEquityRatio <= 1.0
        ? rawEquityRatio * 100.0
        : rawEquityRatio;

    return FinancialSummary(
      code: json['Code']?.toString() ?? json['LocalCode']?.toString() ?? json['code']?.toString() ?? '',
      periodEnd: parsedDate,
      revenue: _firstValidDouble(json, [
        'Sales', 'NetSales', 'TotalRevenue', 'OperatingRevenue', 'revenue',
      ]),
      operatingProfit: _firstValidDouble(json, [
        'OP', 'OperatingProfit', 'operatingProfit',
      ]),
      ordinaryProfit: _firstValidDouble(json, [
        'OdP', 'OrdinaryProfit', 'ordinaryProfit',
      ]),
      netIncome: _firstValidDouble(json, [
        'NP', 'Profit', 'netIncome',
      ]),
      // ①予想EPS → ②実績EPS の順で有効値を取得（"-"をスキップ）
      eps: _firstValidDouble(json, [
        'FEPS',
        'ForecastEarningsPerShare',
        'EPS',
        'EarningsPerShare',
        'eps',
      ]),
      bps: _firstValidDouble(json, [
        'BPS', 'BookValuePerShare', 'bps',
      ]),
      dividendPerShare: _extractDividend(json),
      issuedShares: _firstValidInt(json, [
        'ShOutFY',
        'ShOutEndPeriod',
        'AvgSh',
        'NumberOfIssuedAndOutstandingSharesAtTheEndOfFiscalYearIncludingTreasuryStock',
        'issuedShares',
      ]),
      equity: _firstValidDouble(json, ['Eq', 'Equity', 'equity']),
      totalAssets: _firstValidDouble(json, ['TA', 'TotalAssets', 'totalAssets']),
      equityRatio: normalizedEquityRatio,
    );
  }

  // ---------------------------------------------------------------------------
  // 有効値フォールバックエンジン
  // ?? 演算子はJSONに "-" や "" が存在すると非nullと見なしてフォールバックしない。
  // このヘルパーは各候補キーを順番にチェックし、最初に有効な数値を持つ値を返す。
  // ---------------------------------------------------------------------------

  /// キーのリストを順に試み、最初に有効な double 値を返す
  static double? _firstValidDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final val = json[key];
      final parsed = _toDouble(val);
      if (parsed != null) return parsed;
    }
    return null;
  }

  /// キーのリストを順に試み、最初に有効な int 値を返す
  static int? _firstValidInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final val = json[key];
      final parsed = _toInt(val);
      if (parsed != null) return parsed;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 複数決算レコード間のフォールバック
  // ---------------------------------------------------------------------------

  /// 複数決算レコードの中から最新の有効なEPS・BPSを持つレコードを返す
  static ({double? eps, double? bps}) findLatestEffectiveFinancials(List<FinancialSummary> list) {
    double? eps;
    double? bps;
    for (final fin in list.reversed) {
      eps ??= fin.eps;
      bps ??= fin.bps;
      if (eps != null && bps != null) break;
    }
    return (eps: eps, bps: bps);
  }

  /// 複数決算レコードから最新の有効な配当金情報を探すヘルパー
  static double? findLatestEffectiveDividend(List<FinancialSummary> list) {
    if (list.isEmpty) return null;
    for (final fin in list.reversed) {
      if (fin.dividendPerShare != null) {
        return fin.dividendPerShare;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 配当金抽出
  // ---------------------------------------------------------------------------

  /// J-Quantsの各配当キーから予想/実績配当額を確実に抽出するヘルパー
  static double? _extractDividend(Map<String, dynamic> json) {
    // 1. 通期予想年間配当 (FDivAnn)
    final fAnn = _firstValidDouble(json, [
      'FDivAnn', 'ForecastDividendPerShareAnnual', 'FDivFYAnnual', 'ForecastAnnualDividendPerShare',
    ]);
    if (fAnn != null && fAnn > 0) return fAnn;

    // 2. 予想中間(FDiv2Q) + 予想期末(FDivFY) の合算
    final f2q = _toDouble(json['FDiv2Q'] ?? json['ForecastDividendPerShare2ndQuarter']);
    final ffy = _toDouble(json['FDivFY'] ?? json['ForecastDividendPerShareFiscalYearEnd']);
    if (f2q != null && ffy != null) {
      final sum = f2q + ffy;
      if (sum > 0) return sum;
    } else if (ffy != null && ffy > 0) {
      return ffy;
    }

    // 3. 実績年間配当 (DivAnn) - 予想未公表時のフォールバック
    final rAnn = _firstValidDouble(json, [
      'DivAnn', 'ResultDividendPerShareAnnual', 'AnnualDividendPerShare', 'DPS', 'dividendPerShare',
    ]);
    if (rAnn != null && rAnn > 0) return rAnn;

    // 4. 実績中間(Div2Q) + 実績期末(DivFY) の合算
    final r2q = _toDouble(json['Div2Q'] ?? json['ResultDividendPerShare2ndQuarter']);
    final rfy = _toDouble(json['DivFY'] ?? json['ResultDividendPerShareFiscalYearEnd']);
    if (r2q != null && rfy != null) {
      final sum = r2q + rfy;
      if (sum > 0) return sum;
    } else if (rfy != null && rfy > 0) {
      return rfy;
    }

    // 5. 各四半期配当の合算 (1Q + 2Q + 3Q + FY)
    final d1 = _toDouble(json['Div1Q'] ?? json['FDiv1Q']) ?? 0.0;
    final d2 = _toDouble(json['Div2Q'] ?? json['FDiv2Q']) ?? 0.0;
    final d3 = _toDouble(json['Div3Q'] ?? json['FDiv3Q']) ?? 0.0;
    final d4 = _toDouble(json['DivFY'] ?? json['FDivFY']) ?? 0.0;
    final totalQuarterly = d1 + d2 + d3 + d4;
    if (totalQuarterly > 0) return totalQuarterly;

    // 6. 明示的な無配 (0円)
    if (fAnn == 0.0 || rAnn == 0.0 || ffy == 0.0 || rfy == 0.0) {
      return 0.0;
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // プリミティブパーサー
  // ---------------------------------------------------------------------------

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    final s = val.toString().trim();
    if (s.isEmpty || s == '-' || s == '－' || s == '―' || s == 'None' || s == 'null' || s == 'N/A') return null;
    if (val is num) return val.toDouble();
    return double.tryParse(s);
  }

  static int? _toInt(dynamic val) {
    if (val == null) return null;
    final s = val.toString().trim();
    if (s.isEmpty || s == '-' || s == '－' || s == '―' || s == 'None' || s == 'null' || s == 'N/A') return null;
    if (val is num) return val.toInt();
    return int.tryParse(s);
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
