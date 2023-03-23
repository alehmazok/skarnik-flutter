import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_word.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/search_repository.dart';

@Injectable(as: SearchRepository)
class ObjectboxSearchRepository implements SearchRepository {
  final ObjectboxService _objectboxService;

  ObjectboxSearchRepository(this._objectboxService);

  @override
  Future<Iterable<Word>> search(String query) async {
    debugPrint('Store: ${_objectboxService.store.hashCode}, ${_objectboxService.store}');

    final box = _objectboxService.store.box<ObjectboxWord>();
    final queryBuilder = box
        .query(
          ObjectboxWord_.lword.startsWith(query) | ObjectboxWord_.lwordMask.startsWith(query),
        )
        .order(ObjectboxWord_.lword)
        .build();

    return queryBuilder.find();
  }
}
