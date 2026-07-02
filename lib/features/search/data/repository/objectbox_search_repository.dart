import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';

import '../../domain/repository/query_repository.dart';
import '../../domain/repository/search_repository.dart';
import '../util/damerau_levenshtein.dart';

@LazySingleton(as: SearchRepository)
class ObjectboxSearchRepository implements SearchRepository {
  static const letterSubstitutions = {
    'и': 'і',
    'е': 'ё',
    'щ': 'ў',
    'ъ': '‘',
    '\'': '‘',
  };

  final QueryRepository _queryRepository;

  ObjectboxSearchRepository(
    this._queryRepository,
  );

  @override
  Future<Iterable<SearchWord>> search(String searchQuery) async {
    searchQuery = searchQuery.toLowerCase();
    final searchQueryWithSubstitutions = applySubstitutions(searchQuery);

    final resultsByWord = _queryRepository.queryByWord(
      searchQuery: searchQuery,
      searchQueryWithSubstitutions: searchQueryWithSubstitutions,
    );

    final resultsByWordMask = _queryRepository.queryByWordMask(
      searchQuery: searchQuery,
      searchQueryWithSubstitutions: searchQueryWithSubstitutions,
      excluded: resultsByWord,
    );

    final combinedExact = <SearchWord>{...resultsByWord, ...resultsByWordMask};

    final fuzzyResults = isFuzzySearchApplicable(searchQuery, combinedExact)
        ? fuzzySearch(searchQueryWithSubstitutions, excluded: combinedExact)
        : const <SearchWord>[];

    /// Рэзультаты абодвух запытаў складваем у LinkedHashSet, на ўсялякі выпадак, каб пазбегнуць дублікатаў.
    /// Але насамрэч дублікатаў не павінна быць яшчэ на ўзроўні запыту да БД.
    /// Глядзі параметр [excluded] ў [QueryRepository.queryByWordMask].
    return <SearchWord>{
      ...resultsByWord,
      ...resultsByWordMask,
      ...fuzzyResults,
    };
  }

  bool isFuzzySearchApplicable(
    String searchQuery,
    Iterable<SearchWord> combinedExact,
  ) => searchQuery.length >= AppConfig.fuzzySearchMinQueryLength && combinedExact.isEmpty;

  Iterable<SearchWord> fuzzySearch(
    String searchQuery, {
    required Iterable<SearchWord> excluded,
  }) {
    // The `letter` column is stored lowercase by the external dictionary
    // build pipeline, like `lword`/`lwordMask` which are also pre-lowercased.
    final candidates = _queryRepository.queryByFirstLetter(
      firstLetter: searchQuery[0],
      excluded: excluded,
    );
    final maxDistance = searchQuery.length <= 5 ? 1 : 2;

    final scored =
        [
          for (final candidate in candidates)
            MapEntry(candidate, damerauLevenshteinDistance(searchQuery, candidate.lword)),
        ].where((entry) => entry.value <= maxDistance).toList()..sort((a, b) {
          final byDistance = a.value.compareTo(b.value);
          return byDistance != 0 ? byDistance : a.key.lword.compareTo(b.key.lword);
        });

    return scored.take(AppConfig.wordsSearchLimit).map((entry) => entry.key);
  }

  String applySubstitutions(String query) {
    for (final entry in letterSubstitutions.entries) {
      query = query.replaceAll(entry.key, entry.value);
    }
    return query;
  }
}
