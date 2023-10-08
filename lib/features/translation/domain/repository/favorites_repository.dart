import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract interface class FavoritesRepository {
  Future<Iterable<Word>> getAll(int offset);

  Future<int> add(Word word);

  Future<bool> remove(Word word);

  Future<bool> contains(Word word);
}
