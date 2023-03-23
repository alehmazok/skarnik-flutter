import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract class SearchRepository {
  const SearchRepository._();

  Future<Iterable<Word>> search(String query);
}
