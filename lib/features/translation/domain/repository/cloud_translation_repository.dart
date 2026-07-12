import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../entity/api_word.dart';
import 'translation_repository.dart';

abstract interface class CloudTranslationRepository implements TranslationRepository {
  /// Total row count for [dictionary] in the cloud source.
  Future<int> countWords(Dictionary dictionary);

  /// Streams all words for [dictionary], paginated in batches of [pageSize].
  Stream<List<ApiWord>> downloadDictionary(Dictionary dictionary, {int pageSize = 5000});
}
