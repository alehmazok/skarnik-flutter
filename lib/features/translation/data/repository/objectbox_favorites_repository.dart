import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_favorite_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/favorites_repository.dart';

@Injectable(as: TranslationFavoritesRepository)
class ObjectboxTranslationFavoritesRepository implements TranslationFavoritesRepository {
  final ObjectboxStoreHolder objectboxService;

  ObjectboxTranslationFavoritesRepository(this.objectboxService);

  @override
  Future<int> add(Word word) async {
    final box = objectboxService.favoritesBox;
    final query = box.query(ObjectboxFavoriteWord_.wordId.equals(word.wordId)).build();
    final alreadyExist = query.count() > 0;
    if (alreadyExist) {
      // Remove the word to maintain Favorites ordering.
      query.remove();
    }
    return box.put(ObjectboxFavoriteWord.fromWord(word));
  }

  @override
  Future<bool> contains(Word word) async {
    final box = objectboxService.favoritesBox;
    final query = box.query(ObjectboxFavoriteWord_.wordId.equals(word.wordId)).build();
    return query.count() > 0;
  }
}
