import 'package:injectable/injectable.dart';
import 'package:rxdart/transformers.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/vocabulary_repository.dart';

@Injectable(as: VocabularyRepository)
class ObjectboxVocabularyRepository implements VocabularyRepository {
  final ObjectboxService _objectboxService;

  ObjectboxVocabularyRepository(this._objectboxService);

  @override
  Future<Iterable<Word>> getWords(int langId) async {
    final query = _objectboxService.searchBox
        .query(ObjectboxSearchWord_.langId.equals(langId))
        .build();
    return query.findAsync();
  }

  @override
  Stream<Iterable<Word>> getStream(int langId) {
    final query = _objectboxService.searchBox
        .query(ObjectboxSearchWord_.langId.equals(langId))
        .build();
    return query.stream().bufferCount(500);
  }
}
