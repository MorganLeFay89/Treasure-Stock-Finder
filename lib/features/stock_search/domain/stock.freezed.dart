// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Stock _$StockFromJson(Map<String, dynamic> json) {
  return _Stock.fromJson(json);
}

/// @nodoc
mixin _$Stock {
  String get stockCode => throw _privateConstructorUsedError;
  String get stockName => throw _privateConstructorUsedError;
  String get market => throw _privateConstructorUsedError;
  String get industry => throw _privateConstructorUsedError;
  double get revenueGrowthRate => throw _privateConstructorUsedError;
  double get operatingProfitGrowthRate => throw _privateConstructorUsedError;
  double get profitMargin => throw _privateConstructorUsedError;
  double get forecastPER => throw _privateConstructorUsedError;
  double get pbr => throw _privateConstructorUsedError;
  double get forecastDividendYield => throw _privateConstructorUsedError;
  double get roe => throw _privateConstructorUsedError;
  double get roa => throw _privateConstructorUsedError;
  double get equityRatio => throw _privateConstructorUsedError;
  int get marketCap => throw _privateConstructorUsedError;
  double? get aiScore => throw _privateConstructorUsedError;

  /// Serializes this Stock to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Stock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockCopyWith<Stock> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockCopyWith<$Res> {
  factory $StockCopyWith(Stock value, $Res Function(Stock) then) =
      _$StockCopyWithImpl<$Res, Stock>;
  @useResult
  $Res call(
      {String stockCode,
      String stockName,
      String market,
      String industry,
      double revenueGrowthRate,
      double operatingProfitGrowthRate,
      double profitMargin,
      double forecastPER,
      double pbr,
      double forecastDividendYield,
      double roe,
      double roa,
      double equityRatio,
      int marketCap,
      double? aiScore});
}

/// @nodoc
class _$StockCopyWithImpl<$Res, $Val extends Stock>
    implements $StockCopyWith<$Res> {
  _$StockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Stock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stockCode = null,
    Object? stockName = null,
    Object? market = null,
    Object? industry = null,
    Object? revenueGrowthRate = null,
    Object? operatingProfitGrowthRate = null,
    Object? profitMargin = null,
    Object? forecastPER = null,
    Object? pbr = null,
    Object? forecastDividendYield = null,
    Object? roe = null,
    Object? roa = null,
    Object? equityRatio = null,
    Object? marketCap = null,
    Object? aiScore = freezed,
  }) {
    return _then(_value.copyWith(
      stockCode: null == stockCode
          ? _value.stockCode
          : stockCode // ignore: cast_nullable_to_non_nullable
              as String,
      stockName: null == stockName
          ? _value.stockName
          : stockName // ignore: cast_nullable_to_non_nullable
              as String,
      market: null == market
          ? _value.market
          : market // ignore: cast_nullable_to_non_nullable
              as String,
      industry: null == industry
          ? _value.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String,
      revenueGrowthRate: null == revenueGrowthRate
          ? _value.revenueGrowthRate
          : revenueGrowthRate // ignore: cast_nullable_to_non_nullable
              as double,
      operatingProfitGrowthRate: null == operatingProfitGrowthRate
          ? _value.operatingProfitGrowthRate
          : operatingProfitGrowthRate // ignore: cast_nullable_to_non_nullable
              as double,
      profitMargin: null == profitMargin
          ? _value.profitMargin
          : profitMargin // ignore: cast_nullable_to_non_nullable
              as double,
      forecastPER: null == forecastPER
          ? _value.forecastPER
          : forecastPER // ignore: cast_nullable_to_non_nullable
              as double,
      pbr: null == pbr
          ? _value.pbr
          : pbr // ignore: cast_nullable_to_non_nullable
              as double,
      forecastDividendYield: null == forecastDividendYield
          ? _value.forecastDividendYield
          : forecastDividendYield // ignore: cast_nullable_to_non_nullable
              as double,
      roe: null == roe
          ? _value.roe
          : roe // ignore: cast_nullable_to_non_nullable
              as double,
      roa: null == roa
          ? _value.roa
          : roa // ignore: cast_nullable_to_non_nullable
              as double,
      equityRatio: null == equityRatio
          ? _value.equityRatio
          : equityRatio // ignore: cast_nullable_to_non_nullable
              as double,
      marketCap: null == marketCap
          ? _value.marketCap
          : marketCap // ignore: cast_nullable_to_non_nullable
              as int,
      aiScore: freezed == aiScore
          ? _value.aiScore
          : aiScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StockImplCopyWith<$Res> implements $StockCopyWith<$Res> {
  factory _$$StockImplCopyWith(
          _$StockImpl value, $Res Function(_$StockImpl) then) =
      __$$StockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String stockCode,
      String stockName,
      String market,
      String industry,
      double revenueGrowthRate,
      double operatingProfitGrowthRate,
      double profitMargin,
      double forecastPER,
      double pbr,
      double forecastDividendYield,
      double roe,
      double roa,
      double equityRatio,
      int marketCap,
      double? aiScore});
}

/// @nodoc
class __$$StockImplCopyWithImpl<$Res>
    extends _$StockCopyWithImpl<$Res, _$StockImpl>
    implements _$$StockImplCopyWith<$Res> {
  __$$StockImplCopyWithImpl(
      _$StockImpl _value, $Res Function(_$StockImpl) _then)
      : super(_value, _then);

  /// Create a copy of Stock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stockCode = null,
    Object? stockName = null,
    Object? market = null,
    Object? industry = null,
    Object? revenueGrowthRate = null,
    Object? operatingProfitGrowthRate = null,
    Object? profitMargin = null,
    Object? forecastPER = null,
    Object? pbr = null,
    Object? forecastDividendYield = null,
    Object? roe = null,
    Object? roa = null,
    Object? equityRatio = null,
    Object? marketCap = null,
    Object? aiScore = freezed,
  }) {
    return _then(_$StockImpl(
      stockCode: null == stockCode
          ? _value.stockCode
          : stockCode // ignore: cast_nullable_to_non_nullable
              as String,
      stockName: null == stockName
          ? _value.stockName
          : stockName // ignore: cast_nullable_to_non_nullable
              as String,
      market: null == market
          ? _value.market
          : market // ignore: cast_nullable_to_non_nullable
              as String,
      industry: null == industry
          ? _value.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String,
      revenueGrowthRate: null == revenueGrowthRate
          ? _value.revenueGrowthRate
          : revenueGrowthRate // ignore: cast_nullable_to_non_nullable
              as double,
      operatingProfitGrowthRate: null == operatingProfitGrowthRate
          ? _value.operatingProfitGrowthRate
          : operatingProfitGrowthRate // ignore: cast_nullable_to_non_nullable
              as double,
      profitMargin: null == profitMargin
          ? _value.profitMargin
          : profitMargin // ignore: cast_nullable_to_non_nullable
              as double,
      forecastPER: null == forecastPER
          ? _value.forecastPER
          : forecastPER // ignore: cast_nullable_to_non_nullable
              as double,
      pbr: null == pbr
          ? _value.pbr
          : pbr // ignore: cast_nullable_to_non_nullable
              as double,
      forecastDividendYield: null == forecastDividendYield
          ? _value.forecastDividendYield
          : forecastDividendYield // ignore: cast_nullable_to_non_nullable
              as double,
      roe: null == roe
          ? _value.roe
          : roe // ignore: cast_nullable_to_non_nullable
              as double,
      roa: null == roa
          ? _value.roa
          : roa // ignore: cast_nullable_to_non_nullable
              as double,
      equityRatio: null == equityRatio
          ? _value.equityRatio
          : equityRatio // ignore: cast_nullable_to_non_nullable
              as double,
      marketCap: null == marketCap
          ? _value.marketCap
          : marketCap // ignore: cast_nullable_to_non_nullable
              as int,
      aiScore: freezed == aiScore
          ? _value.aiScore
          : aiScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StockImpl implements _Stock {
  const _$StockImpl(
      {required this.stockCode,
      required this.stockName,
      required this.market,
      required this.industry,
      required this.revenueGrowthRate,
      required this.operatingProfitGrowthRate,
      required this.profitMargin,
      required this.forecastPER,
      required this.pbr,
      required this.forecastDividendYield,
      required this.roe,
      required this.roa,
      required this.equityRatio,
      required this.marketCap,
      this.aiScore});

  factory _$StockImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockImplFromJson(json);

  @override
  final String stockCode;
  @override
  final String stockName;
  @override
  final String market;
  @override
  final String industry;
  @override
  final double revenueGrowthRate;
  @override
  final double operatingProfitGrowthRate;
  @override
  final double profitMargin;
  @override
  final double forecastPER;
  @override
  final double pbr;
  @override
  final double forecastDividendYield;
  @override
  final double roe;
  @override
  final double roa;
  @override
  final double equityRatio;
  @override
  final int marketCap;
  @override
  final double? aiScore;

  @override
  String toString() {
    return 'Stock(stockCode: $stockCode, stockName: $stockName, market: $market, industry: $industry, revenueGrowthRate: $revenueGrowthRate, operatingProfitGrowthRate: $operatingProfitGrowthRate, profitMargin: $profitMargin, forecastPER: $forecastPER, pbr: $pbr, forecastDividendYield: $forecastDividendYield, roe: $roe, roa: $roa, equityRatio: $equityRatio, marketCap: $marketCap, aiScore: $aiScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockImpl &&
            (identical(other.stockCode, stockCode) ||
                other.stockCode == stockCode) &&
            (identical(other.stockName, stockName) ||
                other.stockName == stockName) &&
            (identical(other.market, market) || other.market == market) &&
            (identical(other.industry, industry) ||
                other.industry == industry) &&
            (identical(other.revenueGrowthRate, revenueGrowthRate) ||
                other.revenueGrowthRate == revenueGrowthRate) &&
            (identical(other.operatingProfitGrowthRate,
                    operatingProfitGrowthRate) ||
                other.operatingProfitGrowthRate == operatingProfitGrowthRate) &&
            (identical(other.profitMargin, profitMargin) ||
                other.profitMargin == profitMargin) &&
            (identical(other.forecastPER, forecastPER) ||
                other.forecastPER == forecastPER) &&
            (identical(other.pbr, pbr) || other.pbr == pbr) &&
            (identical(other.forecastDividendYield, forecastDividendYield) ||
                other.forecastDividendYield == forecastDividendYield) &&
            (identical(other.roe, roe) || other.roe == roe) &&
            (identical(other.roa, roa) || other.roa == roa) &&
            (identical(other.equityRatio, equityRatio) ||
                other.equityRatio == equityRatio) &&
            (identical(other.marketCap, marketCap) ||
                other.marketCap == marketCap) &&
            (identical(other.aiScore, aiScore) || other.aiScore == aiScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stockCode,
      stockName,
      market,
      industry,
      revenueGrowthRate,
      operatingProfitGrowthRate,
      profitMargin,
      forecastPER,
      pbr,
      forecastDividendYield,
      roe,
      roa,
      equityRatio,
      marketCap,
      aiScore);

  /// Create a copy of Stock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockImplCopyWith<_$StockImpl> get copyWith =>
      __$$StockImplCopyWithImpl<_$StockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockImplToJson(
      this,
    );
  }
}

abstract class _Stock implements Stock {
  const factory _Stock(
      {required final String stockCode,
      required final String stockName,
      required final String market,
      required final String industry,
      required final double revenueGrowthRate,
      required final double operatingProfitGrowthRate,
      required final double profitMargin,
      required final double forecastPER,
      required final double pbr,
      required final double forecastDividendYield,
      required final double roe,
      required final double roa,
      required final double equityRatio,
      required final int marketCap,
      final double? aiScore}) = _$StockImpl;

  factory _Stock.fromJson(Map<String, dynamic> json) = _$StockImpl.fromJson;

  @override
  String get stockCode;
  @override
  String get stockName;
  @override
  String get market;
  @override
  String get industry;
  @override
  double get revenueGrowthRate;
  @override
  double get operatingProfitGrowthRate;
  @override
  double get profitMargin;
  @override
  double get forecastPER;
  @override
  double get pbr;
  @override
  double get forecastDividendYield;
  @override
  double get roe;
  @override
  double get roa;
  @override
  double get equityRatio;
  @override
  int get marketCap;
  @override
  double? get aiScore;

  /// Create a copy of Stock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockImplCopyWith<_$StockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
