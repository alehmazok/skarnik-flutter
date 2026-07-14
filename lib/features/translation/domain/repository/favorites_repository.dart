import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/favorites/domain/entity/favorites_sort_order.dart';

abstract interface class FavoritesRepository {
  Future<Iterable<Word>> getAll(int offset, FavoritesSortOrder sortOrder);

  Future<int> add(Word word);

  Future<bool> remove(Word word);

  Future<bool> contains(Word word);
}
