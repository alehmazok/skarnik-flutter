import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';
import 'package:skarnik_flutter/logging.dart';
import 'package:skarnik_flutter/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entity/api_word.dart';
import '../../domain/entity/download_page.dart';
import '../../domain/repository/cloud_translation_repository.dart';
import '../model/cloud_word_model.dart';

@LazySingleton(as: CloudTranslationRepository)
class SupabaseTranslationRepositoryImpl implements CloudTranslationRepository {
  static const _table = 'main_word';
  static const _downloadColumns = 'id, external_id, stress, translation, redirect_to';

  final _logger = getLogger(SupabaseTranslationRepositoryImpl);

  @override
  Future<ApiWord> getWord(Word word) async {
    _logger.fine('Fetching translation for wordId: ${word.wordId}');

    final response = await SupabaseConfig.client
        .from(_table)
        .select()
        .eq('external_id', word.wordId)
        .eq('direction', word.dictionary.path)
        .maybeSingle();

    if (response == null) {
      throw Exception('Translation not found for wordId: ${word.wordId}');
    }

    final model = CloudWordModel.fromJson(response);

    return model.toEntity();
  }

  @override
  Future<Translation> getTranslation(Word word) {
    throw UnimplementedError();
  }

  @override
  Future<int> countWords(Dictionary dictionary) async {
    final response = await SupabaseConfig.client
        .from(_table)
        .select('id')
        .eq('direction', dictionary.path)
        .limit(1)
        .count(CountOption.exact);

    return response.count;
  }

  @override
  Stream<DownloadPage> downloadDictionary(
    Dictionary dictionary, {
    int pageSize = 5000,
    int startCursor = 0,
  }) async* {
    var cursor = startCursor;
    while (true) {
      final rows = await _fetchPageWithRetry(dictionary, cursor, pageSize);

      if (rows.isEmpty) {
        return;
      }

      cursor = rows.last['id'] as int;
      yield DownloadPage(
        words: rows.map((row) => CloudWordModel.fromJson(row).toEntity()).toList(),
        cursor: cursor,
      );
    }
  }

  // A ~20-request sequential download (5000 rows/page) is long enough that a
  // single transient failure (seen in practice: PostgrestException 57014
  // "canceling statement due to statement timeout" on an otherwise-cheap
  // indexed query, plus plain network blips) shouldn't abort the whole
  // batch. `on Exception` (not `PostgrestException` alone) also covers
  // SocketException/ClientException/TimeoutException, which otherwise skip
  // retry entirely; `Error` subtypes still propagate immediately since they
  // indicate a bug, not a transient condition.
  static const _maxPageAttempts = 5;

  Future<List<Map<String, dynamic>>> _fetchPageWithRetry(
    Dictionary dictionary,
    int cursor,
    int pageSize,
  ) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await SupabaseConfig.client
            .from(_table)
            .select(_downloadColumns)
            .eq('direction', dictionary.path)
            .gt('id', cursor)
            .order('id', ascending: true)
            .limit(pageSize);
      } on Exception catch (e, st) {
        if (attempt >= _maxPageAttempts) rethrow;
        _logger.warning('Page fetch failed (attempt $attempt/$_maxPageAttempts), retrying:', e, st);
        await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }
}
