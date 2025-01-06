import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/query_repository.dart';

@LazySingleton(as: QueryRepository)
class QueryRepositoryImpl implements QueryRepository {
  final ObjectboxStoreHolder _objectboxService;

  QueryRepositoryImpl(this._objectboxService);

  @override
  Iterable<ObjectboxSearchWord> queryByWord({
    required String searchQuery,
    required String searchQueryWithSubstitutions,
  }) {
    final box = _objectboxService.searchStore.box<ObjectboxSearchWord>();
    final query = box
        .query(
          ObjectboxSearchWord_.lword
              .startsWith(searchQuery)
              .or(ObjectboxSearchWord_.lword.startsWith(searchQueryWithSubstitutions)),
        )
        .order(ObjectboxSearchWord_.lword)
        .build();
    return query.find();
  }

  @override
  Iterable<ObjectboxSearchWord> queryByWordMask({
    required String searchQuery,
    required String searchQueryWithSubstitutions,
  }) {
    final box = _objectboxService.searchStore.box<ObjectboxSearchWord>();
    final query = box
        .query(
          ObjectboxSearchWord_.lwordMask
              .startsWith(searchQuery)
              .or(ObjectboxSearchWord_.lwordMask.startsWith(searchQueryWithSubstitutions)),
        )
        .order(ObjectboxSearchWord_.lwordMask)
        .build();
    return query.find();
  }
}
