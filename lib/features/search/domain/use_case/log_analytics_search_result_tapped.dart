import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_search_repository.dart';

@injectable
class LogAnalyticsSearchResultTappedUseCase {
  final _logger = getLogger(LogAnalyticsSearchResultTappedUseCase);

  final AnalyticsSearchRepository _analyticsSearchRepository;

  LogAnalyticsSearchResultTappedUseCase(this._analyticsSearchRepository);

  Future<UseCaseResult<bool>> call(({SearchWord word, int position, String query}) argument) async {
    try {
      await _analyticsSearchRepository.logSearchResultTapped(
        argument.word,
        argument.position,
        argument.query,
      );
    } catch (e, st) {
      _logger.warning(
        'Адбылася памылка пры спробе залагіраваць падзею націску на вынік пошуку `${argument.word.word}`:',
        e,
        st,
      );
    }
    return const Success(true);
  }
}
