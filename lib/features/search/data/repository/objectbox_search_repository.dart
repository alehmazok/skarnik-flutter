import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/search_repository.dart';

@Injectable(as: SearchRepository)
class ObjectboxSearchRepository implements SearchRepository {
  static const letterSubstitutions = {
    'и': 'і',
    'е': 'ё',
    'щ': 'ў',
    'ъ': '‘',
    '\'': '‘',
  };

  final ObjectboxService _objectboxService;

  ObjectboxSearchRepository(this._objectboxService);

  @override
  Future<Iterable<Word>> search(String query) async {
    query = query.toLowerCase();
    final box = _objectboxService.searchStore.box<ObjectboxSearchWord>();

    final searchByWord = box
        .query(
          ObjectboxSearchWord_.lword.startsWith(query),
        )
        .order(ObjectboxSearchWord_.lword)
        .build();

    // Калі не адшукалі нічога наўпрост па слову, то падмяняем літары [letterSubstitutions] і шукаем па масцы.
    if (isSearchByMaskApplicable(query) && searchByWord.count() == 0) {
      query = applySubstitutions(query);
      final searchByMask = box
          .query(
            ObjectboxSearchWord_.lwordMask.startsWith(query),
          )
          .order(ObjectboxSearchWord_.lword)
          .build();
      return searchByMask.find();
    }
    return searchByWord.find();
  }

  bool isSearchByMaskApplicable(String query) => query.length >= 3;

  String applySubstitutions(String query) {
    for (final entry in letterSubstitutions.entries) {
      query = query.replaceAll(entry.key, entry.value);
    }
    return query;
  }
}
