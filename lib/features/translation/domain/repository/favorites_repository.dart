import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract interface class FavoritesRepository {
  Future<int> add(Word word);
}
