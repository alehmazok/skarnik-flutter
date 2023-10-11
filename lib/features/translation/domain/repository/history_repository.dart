import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract interface class HistoryRepository {
  Future<Iterable<Word>> getAll(int offset);

  Future<int> save(Word word);
}
