import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract interface class FavoritesRepository {
  Future<Iterable<Word>> getAll(int offset);
}
