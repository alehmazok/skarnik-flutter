import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_favorite_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/favorites_repository.dart';

@Injectable(as: FavoritesRepository)
class ObjectboxFavoritesRepository implements FavoritesRepository {
  final ObjectboxService objectboxService;

  ObjectboxFavoritesRepository(this.objectboxService);

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
}
