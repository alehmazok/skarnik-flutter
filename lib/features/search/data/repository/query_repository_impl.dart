import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/query_repository.dart';

@LazySingleton(as: QueryRepository)
class QueryRepositoryImpl implements QueryRepository {
  static const _aliasSearchQuery = 'search_query_no_subs';
  static const _aliasSearchQueryWithSubstitutions = 'search_query_with_subs';
  static const _aliasExcluded = 'excluded';
  static const _aliasFirstLetter = 'first_letter';
  static const _aliasExcludedFirstLetter = 'excluded_first_letter';

  final ObjectboxStoreHolder _objectboxService;
  late final Query<SearchWord> _queryByWord;
  late final Query<SearchWord> _queryByWordMask;
  late final Query<SearchWord> _queryByFirstLetter;

  QueryRepositoryImpl(this._objectboxService) {
    final box = _objectboxService.searchStore.box<ObjectboxSearchWord>();

    _queryByWord =
        box
            .query(
              ObjectboxSearchWord_.lword
                  .startsWith('', alias: _aliasSearchQuery)
                  .or(
                    ObjectboxSearchWord_.lword.startsWith(
                      '',
                      alias: _aliasSearchQueryWithSubstitutions,
                    ),
                  ),
            )
            .order(ObjectboxSearchWord_.lword)
            .build()
          ..limit = AppConfig.wordsSearchLimit;

    _queryByWordMask =
        box
            .query(
              ObjectboxSearchWord_.lwordMask
                  .startsWith('', alias: _aliasSearchQuery)
                  .or(
                    ObjectboxSearchWord_.lwordMask.startsWith(
                      '',
                      alias: _aliasSearchQueryWithSubstitutions,
                    ),
                  )
                  .and(
                    ObjectboxSearchWord_.id.notOneOf([], alias: _aliasExcluded),
                  ),
            )
            .order(ObjectboxSearchWord_.lwordMask)
            .build()
          ..limit = AppConfig.wordsSearchLimit;

    _queryByFirstLetter =
        box
            .query(
              ObjectboxSearchWord_.letter
                  .equals('', alias: _aliasFirstLetter)
                  .and(
                    ObjectboxSearchWord_.id.notOneOf(
                      [],
                      alias: _aliasExcludedFirstLetter,
                    ),
                  ),
            )
            // No .order() here: candidates are fully re-sorted by edit
            // distance in ObjectboxSearchRepository.fuzzySearch(), so
            // ordering this (potentially tens-of-thousands-row) query by
            // lword would just be wasted native sort work.
            .build()
          ..limit = AppConfig.fuzzySearchCandidateLimit;
  }

  @override
  Iterable<SearchWord> queryByWord({
    required String searchQuery,
    required String searchQueryWithSubstitutions,
  }) {
    final query = _queryByWord
      ..param(
        ObjectboxSearchWord_.lword,
        alias: _aliasSearchQuery,
      ).value = searchQuery
      ..param(
        ObjectboxSearchWord_.lword,
        alias: _aliasSearchQueryWithSubstitutions,
      ).value = searchQueryWithSubstitutions;
    return query.find();
  }

  @override
  Iterable<SearchWord> queryByWordMask({
    required String searchQuery,
    required String searchQueryWithSubstitutions,
    required Iterable<SearchWord> excluded,
  }) {
    final query = _queryByWordMask
      ..param(
        ObjectboxSearchWord_.lwordMask,
        alias: _aliasSearchQuery,
      ).value = searchQuery
      ..param(
        ObjectboxSearchWord_.lwordMask,
        alias: _aliasSearchQueryWithSubstitutions,
      ).value = searchQueryWithSubstitutions
      ..param(
        ObjectboxSearchWord_.id,
        alias: _aliasExcluded,
      ).values = excluded.isEmpty
          ? [0]
          : excluded.map((it) => it.id).toList();
    return query.find();
  }

  @override
  Iterable<SearchWord> queryByFirstLetter({
    required String firstLetter,
    required Iterable<SearchWord> excluded,
  }) {
    final query = _queryByFirstLetter
      ..param(
        ObjectboxSearchWord_.letter,
        alias: _aliasFirstLetter,
      ).value = firstLetter
      ..param(
        ObjectboxSearchWord_.id,
        alias: _aliasExcludedFirstLetter,
      ).values = excluded.isEmpty
          ? [0]
          : excluded.map((it) => it.id).toList();
    return query.find();
  }
}
