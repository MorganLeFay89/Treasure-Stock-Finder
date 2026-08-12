import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/core/api_error.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_data/application/valuation_calculator.dart';
import 'package:finance/features/stock_data/data/jquants_api_client.dart';
import 'package:finance/features/stock_data/data/stock_local_cache_repository.dart';
import 'package:finance/features/stock_data/domain/stock_master.dart';
import 'package:finance/features/stock_search/domain/stock.dart';

/// 同期進捗ステータスモデル
class SyncProgressStatus {
  final bool isRunning;
  final int totalCount;
  final int cachedCount;
  final int currentIndex;
  final String? currentSyncingCode;
  final String? currentSyncingName;
  final String? errorMessage;
  final bool isRateLimited;

  const SyncProgressStatus({
    this.isRunning = false,
    this.totalCount = 0,
    this.cachedCount = 0,
    this.currentIndex = 0,
    this.currentSyncingCode,
    this.currentSyncingName,
    this.errorMessage,
    this.isRateLimited = false,
  });

  SyncProgressStatus copyWith({
    bool? isRunning,
    int? totalCount,
    int? cachedCount,
    int? currentIndex,
    String? currentSyncingCode,
    String? currentSyncingName,
    String? errorMessage,
    bool? isRateLimited,
  }) {
    return SyncProgressStatus(
      isRunning: isRunning ?? this.isRunning,
      totalCount: totalCount ?? this.totalCount,
      cachedCount: cachedCount ?? this.cachedCount,
      currentIndex: currentIndex ?? this.currentIndex,
      currentSyncingCode: currentSyncingCode ?? this.currentSyncingCode,
      currentSyncingName: currentSyncingName ?? this.currentSyncingName,
      errorMessage: errorMessage,
      isRateLimited: isRateLimited ?? this.isRateLimited,
    );
  }
}

final jquantsSyncServiceProvider =
    StateNotifierProvider<JQuantsSyncNotifier, SyncProgressStatus>((ref) {
  return JQuantsSyncNotifier();
});

class JQuantsSyncNotifier extends StateNotifier<SyncProgressStatus> {
  final JQuantsApiClient _apiClient;
  final StockLocalCacheRepository _cacheRepo;
  Timer? _timer;
  List<StockMaster> _stockMasters = [];
  bool _isProcessingStep = false;

  JQuantsSyncNotifier({
    JQuantsApiClient? apiClient,
    StockLocalCacheRepository? cacheRepo,
  })  : _apiClient = apiClient ?? JQuantsApiClient(),
        _cacheRepo = cacheRepo ?? StockLocalCacheRepository(),
        super(const SyncProgressStatus()) {
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    if (!EnvConfig.isJquantsApiKeySet) {
      state = state.copyWith(errorMessage: 'J-Quants APIキーが未設定です。');
      return;
    }

    try {
      // 1. 銘柄マスター一覧の取得
      _stockMasters = await _apiClient.fetchStockList();
      final cachedCount = await _cacheRepo.getCachedCount();

      state = state.copyWith(
        isRunning: true,
        totalCount: _stockMasters.length,
        cachedCount: cachedCount,
      );

      // 5リクエスト/分 (約12秒〜15秒に1リクエスト) に抑える安全タイマー
      // 1銘柄につき株価・財務の2リクエストを行うため、25秒間隔で実行
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 25), (_) {
        _syncStep();
      });

      // 初回即時実行
      _syncStep();
    } catch (e) {
      if (kDebugMode) {
        print('[JQuantsSyncNotifier] 初期化エラー: $e');
      }
      state = state.copyWith(errorMessage: '銘柄一覧の取得に失敗しました。');
    }
  }

  Future<void> _syncStep() async {
    if (_isProcessingStep || _stockMasters.isEmpty) return;
    _isProcessingStep = true;

    // 「①未保存の銘柄最優先 ➔ ②保存済みの中で更新日時が最も古い銘柄」を動的選出
    final targetMaster = await _cacheRepo.getNextSyncTarget(_stockMasters);
    if (targetMaster == null) {
      _isProcessingStep = false;
      return;
    }

    state = state.copyWith(
      currentSyncingCode: targetMaster.code,
      currentSyncingName: targetMaster.name,
      isRateLimited: false,
    );

    try {
      if (kDebugMode) {
        print('[JQuantsSyncNotifier] 同期ターゲット選択: ${targetMaster.code} ${targetMaster.name}');
      }

      final prices = await _apiClient.fetchDailyPrices(code: targetMaster.code);
      final financials = await _apiClient.fetchFinancialStatements(code: targetMaster.code);

      final latestPrice = prices.isNotEmpty ? prices.last : null;
      final latestFinancial = financials.isNotEmpty ? financials.last : null;
      final previousFinancial = financials.length >= 2 ? financials[financials.length - 2] : null;

      final metrics = ValuationCalculator.calculateMetrics(
        code: targetMaster.code,
        latestPrice: latestPrice,
        latestFinancial: latestFinancial,
        previousFinancial: previousFinancial,
      );

      final revenueGrowth = ValuationCalculator.calculateRevenueGrowthRate(
        currentRevenue: latestFinancial?.revenue,
        previousRevenue: previousFinancial?.revenue,
      );

      final opGrowth = ValuationCalculator.calculateOperatingProfitGrowthRate(
        currentOp: latestFinancial?.operatingProfit,
        previousOp: previousFinancial?.operatingProfit,
      );

      final profitMargin = ValuationCalculator.calculateProfitMargin(
        operatingProfit: latestFinancial?.operatingProfit,
        revenue: latestFinancial?.revenue,
      );

      final roe = ValuationCalculator.calculateROE(
        eps: latestFinancial?.eps,
        bps: latestFinancial?.bps,
      );

      final stock = Stock(
        stockCode: targetMaster.code,
        stockName: targetMaster.name,
        market: targetMaster.market,
        industry: targetMaster.sector,
        revenueGrowthRate: revenueGrowth ?? 0.0,
        operatingProfitGrowthRate: opGrowth ?? 0.0,
        profitMargin: profitMargin ?? 0.0,
        forecastPER: metrics.per ?? 0.0,
        pbr: metrics.pbr ?? 0.0,
        forecastDividendYield: metrics.dividendYield ?? 0.0,
        roe: roe ?? 0.0,
        roa: 0.0,
        equityRatio: 0.0,
        marketCap: metrics.marketCap?.toInt() ?? 0,
        aiScore: null,
      );

      // ローカル保存（最終更新日時も自動記録）
      await _cacheRepo.saveStock(stock);

      final newCachedCount = await _cacheRepo.getCachedCount();
      state = state.copyWith(
        cachedCount: newCachedCount,
        isRateLimited: false,
      );
    } on ApiRateLimitException {
      if (kDebugMode) {
        print('[JQuantsSyncNotifier] レートリミット検出: 一時待機します');
      }
      state = state.copyWith(
        isRateLimited: true,
        errorMessage: 'APIレート制限に達したため待機中',
      );
    } catch (e) {
      if (kDebugMode) {
        print('[JQuantsSyncNotifier] ${targetMaster.code} 同期エラー: $e');
      }
    } finally {
      _isProcessingStep = false;
    }
  }

  /// 手動での再開・更新
  void restartSync() {
    _initAndStart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
