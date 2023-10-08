import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract interface class TranslationFavoritesRepository {
  Future<int> add(Word word);

  Future<bool> contains(Word word);
}
