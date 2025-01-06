import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';

abstract class SearchRepository {
  const SearchRepository._();

  Future<Iterable<SearchWord>> search(String query);
}
