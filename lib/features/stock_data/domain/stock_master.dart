/// 上場銘柄基本情報モデル
class StockMaster {
  final String code;
  final String name;
  final String market;
  final String sector;

  const StockMaster({
    required this.code,
    required this.name,
    required this.market,
    required this.sector,
  });

  factory StockMaster.fromJson(Map<String, dynamic> json) {
    return StockMaster(
      code: json['Code']?.toString() ?? json['code']?.toString() ?? '',
      name: json['CoName']?.toString() ??
          json['CompanyName']?.toString() ??
          json['name']?.toString() ??
          '',
      market: json['MktNm']?.toString() ??
          json['MarketCodeName']?.toString() ??
          json['market']?.toString() ??
          '未分類',
      sector: json['S17Nm']?.toString() ??
          json['Sector17CodeName']?.toString() ??
          json['sector']?.toString() ??
          'その他',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'market': market,
      'sector': sector,
    };
  }
}
