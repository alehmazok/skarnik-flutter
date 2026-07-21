import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/repository/analytics_search_repository.dart';

@dev
@Injectable(as: AnalyticsSearchRepository)
class DevAnalyticsSearchRepository implements AnalyticsSearchRepository {
  final _logger = getLogger(DevAnalyticsSearchRepository);

  @override
  Future<void> logSearchPerformed(String query, int resultCount) async {
    _logger.info(
      'Analytics event logged: search_performed {"query": "$query", "result_count": $resultCount}',
    );
  }

  @override
  Future<void> logSearchNoResults(String query) async {
    _logger.info('Analytics event logged: search_no_results {"query": "$query"}');
  }

  @override
  Future<void> logSearchResultTapped(SearchWord word, int position, String query) async {
    _logger.info(
      'Analytics event logged: search_result_tapped {"word": "${word.word}", "position": $position}',
    );
  }
}
