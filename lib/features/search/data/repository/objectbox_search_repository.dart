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

  /// RU/BE one-letter prepositions and conjunctions, derived from the
  /// dictionary's own part-of-speech tags (see main_word translations
  /// tagged "предлог/прыназоўнік"/"союз/злучнік"). Users often type these
  /// glued to the next word (e.g. "всмысле" for "в смысле").
  static const _gluedPrefixLetters = {
    'а',
    'в',
    'ж',
    'з',
    'и',
    'і',
    'к',
    'о',
    'с',
    'у',
    'ў',
  };

  final QueryRepository _queryRepository;

  ObjectboxSearchRepository(
    this._queryRepository,
  );

  @override
  Future<({Iterable<SearchWord> words, bool usedPrepositionFallback})> search(
    String searchQuery,
  ) async {
    searchQuery = searchQuery.toLowerCase();
    final primaryResults = await _searchOnce(searchQuery);
    if (primaryResults.isNotEmpty) {
      return (words: primaryResults, usedPrepositionFallback: false);
    }

    final strippedQuery = _stripGluedPrefixLetter(searchQuery);
    if (strippedQuery == null) {
      return (words: primaryResults, usedPrepositionFallback: false);
    }

    final retryResults = await _searchOnce(strippedQuery);
    return (words: retryResults, usedPrepositionFallback: true);
  }

  /// Returns [searchQuery] with a leading glued preposition/conjunction
  /// removed, or null if no such stripping applies. Only ever called on
  /// the original query, never on its own output, so it can strip at
  /// most one letter.
  String? _stripGluedPrefixLetter(String searchQuery) {
    if (searchQuery.length < 2) return null;
    if (!_gluedPrefixLetters.contains(searchQuery[0])) return null;
    return searchQuery.substring(1);
  }

  Future<Iterable<SearchWord>> _searchOnce(String searchQuery) async {
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
