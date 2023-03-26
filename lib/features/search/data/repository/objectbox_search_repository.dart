import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/search_repository.dart';

@Injectable(as: SearchRepository)
class ObjectboxSearchRepository implements SearchRepository {
  final ObjectboxService _objectboxService;

  ObjectboxSearchRepository(this._objectboxService);

  @override
  Future<Iterable<Word>> search(String query) async {
    final box = _objectboxService.searchStore.box<ObjectboxSearchWord>();
    final queryBuilder = box
        .query(
          ObjectboxSearchWord_.lword.startsWith(query) | ObjectboxSearchWord_.lwordMask.startsWith(query),
        )
        .order(ObjectboxSearchWord_.lword)
        .build();

    return queryBuilder.find();
  }
}
