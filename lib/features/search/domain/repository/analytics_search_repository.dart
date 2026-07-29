import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';

abstract class AnalyticsSearchRepository {
  const AnalyticsSearchRepository._();

  Future<void> logSearchPerformed(
    String query,
    int resultCount, {
    bool usedPrepositionFallback = false,
  });

  Future<void> logSearchNoResults(String query, {bool usedPrepositionFallback = false});

  Future<void> logSearchResultTapped(SearchWord word, int position, String query);
}
