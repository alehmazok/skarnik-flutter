import 'package:injectable/injectable.dart' show Injectable;
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_favorite_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/favorites_repository.dart';

@Injectable(as: FavoritesRepository)
class ObjectboxFavoritesRepository implements FavoritesRepository {
  final ObjectboxStoreHolder _objectboxStoreHolder;

  ObjectboxFavoritesRepository(this._objectboxStoreHolder);

  @override
  Future<Iterable<Word>> getAll(int offset) async {
    final query = _objectboxStoreHolder.favoritesBox
        .query()
        .order(
          ObjectboxFavoriteWord_.id,
          flags: Order.descending,
        )
        .build()
      ..limit = AppConfig.wordsPerPage
      ..offset = offset;
    return query.findAsync();
  }

  @override
  Future<bool> remove(Word word) async {
    final box = _objectboxStoreHolder.favoritesBox;
    final query = box
        .query(
          ObjectboxFavoriteWord_.wordId
              .equals(
                word.wordId,
              )
              .and(
                ObjectboxFavoriteWord_.langId.equals(word.langId),
              ),
        )
        .build();
    final alreadyExist = query.count() > 0;
    if (alreadyExist) {
      query.remove();
    }
    return true;
  }

  @override
  Future<int> add(Word word) async {
    final box = _objectboxStoreHolder.favoritesBox;
    final query = box
        .query(
          ObjectboxFavoriteWord_.wordId
              .equals(
                word.wordId,
              )
              .and(
                ObjectboxFavoriteWord_.langId.equals(word.langId),
              ),
        )
        .build();
    final alreadyExist = query.count() > 0;
    if (alreadyExist) {
      // Remove the word to maintain Favorites ordering.
      query.remove();
    }
    return box.put(ObjectboxFavoriteWord.fromWord(word));
  }

  @override
  Future<bool> contains(Word word) async {
    final box = _objectboxStoreHolder.favoritesBox;
    final query = box
        .query(
          ObjectboxFavoriteWord_.wordId
              .equals(
                word.wordId,
              )
              .and(
                ObjectboxFavoriteWord_.langId.equals(word.langId),
              ),
        )
        .build();
    return query.count() > 0;
  }
}
