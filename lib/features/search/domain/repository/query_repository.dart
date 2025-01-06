import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';

abstract interface class QueryRepository {
  Iterable<SearchWord> queryByWord({
    required String searchQuery,
    required String searchQueryWithSubstitutions,
  });

  Iterable<SearchWord> queryByWordMask({
    required String searchQuery,
    required String searchQueryWithSubstitutions,
    required Iterable<SearchWord> excluded,
  });
}
