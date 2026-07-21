import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_search_repository.dart';

@injectable
class LogAnalyticsSearchNoResultsUseCase {
  final _logger = getLogger(LogAnalyticsSearchNoResultsUseCase);

  final AnalyticsSearchRepository _analyticsSearchRepository;

  LogAnalyticsSearchNoResultsUseCase(this._analyticsSearchRepository);

  Future<UseCaseResult<bool>> call(String query) async {
    try {
      await _analyticsSearchRepository.logSearchNoResults(query);
    } catch (e, st) {
      _logger.warning(
        'Адбылася памылка пры спробе залагіраваць падзею пустога пошуку `$query`:',
        e,
        st,
      );
    }
    return const Success(true);
  }
}
