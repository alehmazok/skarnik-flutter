import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/query_repository.dart';
import '../util/fuzzy_candidate_ranking.dart';

class _FuzzySearchParams {
  final String firstLetter;
  final String searchQuery;
  final int maxDistance;
  final int resultLimit;
  final List<int> excludedIds;

  const _FuzzySearchParams({
    required this.firstLetter,
    required this.searchQuery,
    required this.maxDistance,
    required this.resultLimit,
    required this.excludedIds,
  });
}

List<ObjectboxSearchWord> _fuzzySearchIsolateCallback(
  Store store,
  _FuzzySearchParams params,
) {
  final box = store.box<ObjectboxSearchWord>();
  final excluded = params.excludedIds.isEmpty ? [0] : params.excludedIds;
  final query =
      box
          .query(
            ObjectboxSearchWord_.letter
                .equals(params.firstLetter)
                .and(ObjectboxSearchWord_.id.notOneOf(excluded)),
          )
          .build()
        ..limit = AppConfig.fuzzySearchCandidateLimit;
  final candidates = query.find();
  query.close();

  return rankFuzzyCandidates(
    candidates,
    searchQuery: params.searchQuery,
    maxDistance: params.maxDistance,
    limit: params.resultLimit,
  );
}

@LazySingleton(as: QueryRepository)
class QueryRepositoryImpl implements QueryRepository {
  static const _aliasSearchQuery = 'search_query_no_subs';
  static const _aliasSearchQueryWithSubstitutions = 'search_query_with_subs';
  static const _aliasExcluded = 'excluded';

  final ObjectboxStoreHolder _objectboxService;
  late final Query<SearchWord> _queryByWord;
  late final Query<SearchWord> _queryByWordMask;

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
  Future<Iterable<SearchWord>> fuzzySearch({
    required String firstLetter,
    required String searchQuery,
    required int maxDistance,
    required int resultLimit,
    required Iterable<SearchWord> excluded,
  }) => _objectboxService.searchStore.runAsync(
    _fuzzySearchIsolateCallback,
    _FuzzySearchParams(
      firstLetter: firstLetter,
      searchQuery: searchQuery,
      maxDistance: maxDistance,
      resultLimit: resultLimit,
      excludedIds: excluded.map((it) => it.id).toList(),
    ),
  );
}
