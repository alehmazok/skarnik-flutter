import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_search_repository.dart';

@injectable
class LogAnalyticsVocabularyShortcutTappedUseCase {
  final _logger = getLogger(LogAnalyticsVocabularyShortcutTappedUseCase);

  final AnalyticsSearchRepository _analyticsSearchRepository;

  LogAnalyticsVocabularyShortcutTappedUseCase(this._analyticsSearchRepository);

  Future<UseCaseResult<bool>> call() async {
    try {
      await _analyticsSearchRepository.logVocabularyShortcutTapped();
    } catch (e, st) {
      _logger.warning(
        'Адбылася памылка пры спробе залагіраваць падзею тыпу па іконцы слоўніка:',
        e,
        st,
      );
    }
    return const Success(true);
  }
}
