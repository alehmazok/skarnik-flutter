import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';

import '../../domain/repository/analytics_search_repository.dart';

@prod
@Injectable(as: AnalyticsSearchRepository)
class FirebaseAnalyticsSearchRepository implements AnalyticsSearchRepository {
  @override
  Future<void> logSearchPerformed(String query, int resultCount) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
      name: 'search_performed',
      parameters: {
        'query': query,
        'result_count': resultCount,
      },
    );
  }

  @override
  Future<void> logSearchNoResults(String query) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
      name: 'search_no_results',
      parameters: {
        'query': query,
      },
    );
  }

  @override
  Future<void> logSearchResultTapped(SearchWord word, int position, String query) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
      name: 'search_result_tapped',
      parameters: {
        'word_id': word.wordId,
        'lang_id': word.langId,
        'word': word.word,
        'dict_name': word.dictionary.name,
        'dict_path': word.dictionary.path,
        'position': position,
        'query': query,
      },
    );
  }
}
