import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
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

  final ObjectboxStoreHolder _objectboxService;

  ObjectboxSearchRepository(this._objectboxService);

  @override
  Future<Iterable<Word>> search(String searchQuery) async {
    searchQuery = searchQuery.toLowerCase();
    final box = _objectboxService.searchStore.box<ObjectboxSearchWord>();

    final searchQueryWithSubstitutions = applySubstitutions(searchQuery);

    final query = box
        .query(
          ObjectboxSearchWord_.lword
              .startsWith(searchQuery)
              .or(ObjectboxSearchWord_.lword.startsWith(searchQueryWithSubstitutions)),
        )
        .order(ObjectboxSearchWord_.lword)
        .build();

    final queryByMask = box
        .query(
          ObjectboxSearchWord_.lwordMask
              .startsWith(searchQuery)
              .or(ObjectboxSearchWord_.lwordMask.startsWith(searchQueryWithSubstitutions)),
        )
        .order(ObjectboxSearchWord_.lwordMask)
        .build();

    // Рэзультаты абодвух запытаў складваем у LinkedHashSet, каб пазбегнуць дублікатаў
    return {
      ...query.find(),
      ...queryByMask.find(),
    }.map(
      (it) => it.toEntity(),
    );
  }

  bool isSearchByMaskApplicable(String query) => query.length >= 3;

  String applySubstitutions(String query) {
    for (final entry in letterSubstitutions.entries) {
      query = query.replaceAll(entry.key, entry.value);
    }
    return query;
  }
}
