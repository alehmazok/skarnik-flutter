import 'package:injectable/injectable.dart';
import 'package:rxdart/transformers.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/vocabulary_repository.dart';

@Injectable(as: VocabularyRepository)
class ObjectboxVocabularyRepository implements VocabularyRepository {
  final ObjectboxStoreHolder _objectboxService;

  ObjectboxVocabularyRepository(this._objectboxService);

  @override
  Future<Iterable<Word>> getWords(int langId) async {
    final query = _objectboxService.searchBox
        .query(
          ObjectboxSearchWord_.langId.equals(langId),
        )
        .build();
    final words = await query.findAsync();
    return words.map((it) => it.toEntity());
  }

  @override
  Stream<Iterable<Word>> getStream(int langId) {
    final query = _objectboxService.searchBox
        .query(
          ObjectboxSearchWord_.langId.equals(langId),
        )
        .build();
    return query.stream().bufferCount(500).map(
          (buffer) => buffer.map((it) => it.toEntity()),
        );
  }
}
