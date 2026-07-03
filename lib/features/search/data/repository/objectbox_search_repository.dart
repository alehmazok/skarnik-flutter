import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';

import '../../domain/repository/query_repository.dart';
import '../../domain/repository/search_repository.dart';

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
        ? await fuzzySearch(searchQueryWithSubstitutions, excluded: combinedExact)
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

  Future<Iterable<SearchWord>> fuzzySearch(
    String searchQuery, {
    required Iterable<SearchWord> excluded,
  }) {
    // The `letter` column is stored lowercase by the external dictionary
    // build pipeline, like `lword`/`lwordMask` which are also pre-lowercased.
    final maxDistance = searchQuery.length <= 5 ? 1 : 2;
    return _queryRepository.fuzzySearch(
      firstLetter: searchQuery[0],
      searchQuery: searchQuery,
      maxDistance: maxDistance,
      resultLimit: AppConfig.wordsSearchLimit,
      excluded: excluded,
    );
  }

  String applySubstitutions(String query) {
    for (final entry in letterSubstitutions.entries) {
      query = query.replaceAll(entry.key, entry.value);
    }
    return query;
  }
}
