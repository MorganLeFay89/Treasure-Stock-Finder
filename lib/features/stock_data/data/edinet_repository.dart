import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/features/stock_data/data/edinet_api_client.dart';
import 'package:finance/features/stock_data/data/edinet_local_cache_repository.dart';
import 'package:finance/features/stock_data/domain/edinet_document.dart';

final edinetApiClientProvider = Provider((ref) => EdinetApiClient());
final edinetLocalCacheRepositoryProvider = Provider((ref) => EdinetLocalCacheRepository());

/// 証券コードに紐づくEDINET書類一覧を取得するプロバイダ
///
/// 外部通信を行わず、ローカルキャッシュから即座に開示書類を取得します。
final edinetDocumentsProvider =
    FutureProvider.family<List<EdinetDocument>, String>((ref, secCode) async {
  final cacheRepo = ref.watch(edinetLocalCacheRepositoryProvider);
  try {
    return await cacheRepo.getCachedDocuments(secCode);
  } catch (_) {
    return [];
  }
});
