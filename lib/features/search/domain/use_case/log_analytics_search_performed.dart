import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_search_repository.dart';

@injectable
class LogAnalyticsSearchPerformedUseCase {
  final _logger = getLogger(LogAnalyticsSearchPerformedUseCase);

  final AnalyticsSearchRepository _analyticsSearchRepository;

  LogAnalyticsSearchPerformedUseCase(this._analyticsSearchRepository);

  Future<UseCaseResult<bool>> call(({String query, int resultCount}) argument) async {
    try {
      await _analyticsSearchRepository.logSearchPerformed(argument.query, argument.resultCount);
    } catch (e, st) {
      _logger.warning(
        'Адбылася памылка пры спробе залагіраваць падзею пошуку `${argument.query}`:',
        e,
        st,
      );
    }
    return const Success(true);
  }
}
