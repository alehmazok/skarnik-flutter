import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../entity/download_page.dart';
import 'translation_repository.dart';

abstract interface class CloudTranslationRepository implements TranslationRepository {
  /// Total row count for [dictionary] in the cloud source.
  Future<int> countWords(Dictionary dictionary);

  /// Streams all words for [dictionary] with [id] greater than [startCursor],
  /// paginated in batches of [pageSize].
  Stream<DownloadPage> downloadDictionary(
    Dictionary dictionary, {
    int pageSize = 5000,
    int startCursor = 0,
  });
}
