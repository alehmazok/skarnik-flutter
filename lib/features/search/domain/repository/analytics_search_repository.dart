import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';

abstract class AnalyticsSearchRepository {
  const AnalyticsSearchRepository._();

  Future<void> logSearchPerformed(String query, int resultCount);

  Future<void> logSearchNoResults(String query);

  Future<void> logSearchResultTapped(SearchWord word, int position, String query);
}
