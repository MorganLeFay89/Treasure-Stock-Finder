/// 日次株価モデル
class DailyStockPrice {
  final String code;
  final DateTime date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final int? volume;

  const DailyStockPrice({
    required this.code,
    required this.date,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
  });

  factory DailyStockPrice.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['Date'] != null) {
      parsedDate = DateTime.tryParse(json['Date'].toString()) ?? DateTime.now();
    } else if (json['date'] != null) {
      parsedDate = DateTime.tryParse(json['date'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return DailyStockPrice(
      code: json['Code']?.toString() ?? json['code']?.toString() ?? '',
      date: parsedDate,
      open: _toDouble(json['O'] ?? json['Open'] ?? json['open']),
      high: _toDouble(json['H'] ?? json['High'] ?? json['high']),
      low: _toDouble(json['L'] ?? json['Low'] ?? json['low']),
      close: _toDouble(
        json['AdjC'] ??
            json['C'] ??
            json['Close'] ??
            json['close'] ??
            json['AdjustmentClose'],
      ),
      volume: _toInt(json['AdjVo'] ?? json['Vo'] ?? json['Volume'] ?? json['volume']),
    );
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  static int? _toInt(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'date': date.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
}
