import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract class VocabularyRepository {
  Future<Iterable<Word>> getWords(int langId);
}
