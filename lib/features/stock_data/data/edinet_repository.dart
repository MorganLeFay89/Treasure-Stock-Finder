import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance/core/env_config.dart';
import 'package:finance/features/stock_data/data/edinet_api_client.dart';
import 'package:finance/features/stock_data/domain/edinet_document.dart';

final edinetApiClientProvider = Provider((ref) => EdinetApiClient());

/// 証券コードに紐づくEDINET書類一覧を取得するプロバイダ
///
/// APIキー未設定時は空リストを返します。
final edinetDocumentsProvider =
    FutureProvider.family<List<EdinetDocument>, String>((ref, secCode) async {
  if (!EnvConfig.isEdinetApiKeySet) {
    return [];
  }

  final client = ref.watch(edinetApiClientProvider);
  try {
    return await client.searchDocumentsBySecCode(secCode: secCode);
  } catch (_) {
    return [];
  }
});
