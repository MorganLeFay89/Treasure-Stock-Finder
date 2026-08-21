import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/core/api_error.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_data/application/valuation_calculator.dart';
import 'package:finance/features/stock_data/data/jquants_api_client.dart';
import 'package:finance/features/stock_data/data/edinet_api_client.dart';
import 'package:finance/features/stock_data/data/stock_local_cache_repository.dart';
import 'package:finance/features/stock_data/data/edinet_local_cache_repository.dart';
import 'package:finance/features/stock_data/domain/stock_master.dart';
import 'package:finance/features/stock_data/domain/financial_summary.dart';
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
  final EdinetApiClient _edinetApiClient;
  final StockLocalCacheRepository _cacheRepo;
  final EdinetLocalCacheRepository _edinetCacheRepo;
  Timer? _timer;
  List<StockMaster> _stockMasters = [];
  bool _isProcessingStep = false;

  JQuantsSyncNotifier({
    JQuantsApiClient? apiClient,
    EdinetApiClient? edinetApiClient,
    StockLocalCacheRepository? cacheRepo,
    EdinetLocalCacheRepository? edinetCacheRepo,
  })  : _apiClient = apiClient ?? JQuantsApiClient(),
        _edinetApiClient = edinetApiClient ?? EdinetApiClient(),
        _cacheRepo = cacheRepo ?? StockLocalCacheRepository(),
        _edinetCacheRepo = edinetCacheRepo ?? EdinetLocalCacheRepository(),
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
      // 1銘柄につきJ-Quants株価・財務およびEDINET書類を統合取得するため、25秒間隔で実行
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
        print('[JQuantsSyncNotifier] 統合同期ターゲット選択: ${targetMaster.code} ${targetMaster.name}');
      }

      // ETF / 投信かどうかの判定
      final isEtf = targetMaster.market.contains('ETF') ||
          targetMaster.sector.contains('ETF') ||
          targetMaster.sector.contains('投信') ||
          targetMaster.name.contains('ETF');
      final String? note = isEtf ? '※ ETF/投資信託のため財務指標（売上高・利益等）はありません' : null;

      // 1. J-Quants 株価・財務データ取得
      final prices = await _apiClient.fetchDailyPrices(code: targetMaster.code);
      final financials = await _apiClient.fetchFinancialStatements(code: targetMaster.code);

      final latestPrice = prices.isNotEmpty ? prices.last : null;
      final latestFinancial = financials.isNotEmpty ? financials.last : null;
      final previousFinancial = financials.length >= 2 ? financials[financials.length - 2] : null;

      final effectiveDividend = FinancialSummary.findLatestEffectiveDividend(financials);
      final effectiveFinancials = FinancialSummary.findLatestEffectiveFinancials(financials);

      // 最新レコードでEPS/BPSが"-"などで欠損している場合、より古いレコードから補完
      final patchedFinancial = latestFinancial == null
          ? null
          : (latestFinancial.eps != null && latestFinancial.bps != null)
              ? latestFinancial
              : FinancialSummary(
                  code: latestFinancial.code,
                  periodEnd: latestFinancial.periodEnd,
                  revenue: latestFinancial.revenue,
                  operatingProfit: latestFinancial.operatingProfit,
                  ordinaryProfit: latestFinancial.ordinaryProfit,
                  netIncome: latestFinancial.netIncome,
                  eps: latestFinancial.eps ?? effectiveFinancials.eps,
                  bps: latestFinancial.bps ?? effectiveFinancials.bps,
                  dividendPerShare: latestFinancial.dividendPerShare,
                  issuedShares: latestFinancial.issuedShares,
                  equity: latestFinancial.equity,
                  totalAssets: latestFinancial.totalAssets,
                  equityRatio: latestFinancial.equityRatio,
                );

      final metrics = ValuationCalculator.calculateMetrics(
        code: targetMaster.code,
        latestPrice: latestPrice,
        latestFinancial: patchedFinancial,
        previousFinancial: previousFinancial,
        effectiveDividend: effectiveDividend,
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
        eps: patchedFinancial?.eps,
        bps: patchedFinancial?.bps,
      );

      final equityRatio = ValuationCalculator.calculateEquityRatio(
        directEquityRatio: latestFinancial?.equityRatio,
        equity: latestFinancial?.equity,
        totalAssets: latestFinancial?.totalAssets,
      );

      final stock = Stock(
        stockCode: JQuantsApiClient.normalizeCode(targetMaster.code),
        stockName: targetMaster.name,
        market: targetMaster.market,
        industry: targetMaster.sector,
        revenueGrowthRate: revenueGrowth,
        operatingProfitGrowthRate: opGrowth,
        profitMargin: profitMargin,
        forecastPER: metrics.per,
        pbr: metrics.pbr,
        psr: metrics.psr,
        peg: metrics.peg,
        forecastDividendYield: metrics.dividendYield,
        roe: roe,
        roa: null,
        equityRatio: equityRatio,
        marketCap: metrics.marketCap?.toInt(),
        aiScore: null,
        note: note,
      );

      // J-Quantsデータをローカル保存（最終更新日時も自動記録）
      await _cacheRepo.saveStock(stock);

      // 2. EDINET データ取得 & ローカル保存
      if (EnvConfig.isEdinetApiKeySet) {
        try {
          final edinetDocs = await _edinetApiClient.searchDocumentsBySecCode(
            secCode: targetMaster.code,
          );
          if (edinetDocs.isNotEmpty) {
            await _edinetCacheRepo.saveDocuments(targetMaster.code, edinetDocs);
            if (kDebugMode) {
              print('[JQuantsSyncNotifier] EDINET書類保存完了 (${targetMaster.code}): ${edinetDocs.length}件');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('[JQuantsSyncNotifier] EDINET取得スキップ (${targetMaster.code}): $e');
          }
        }
      }

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
