import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_settings_repository.dart';

@injectable
class LogAnalyticsDictionaryDownloadUseCase {
  final _logger = getLogger(LogAnalyticsDictionaryDownloadUseCase);

  final AnalyticsSettingsRepository _analyticsSettingsRepository;

  LogAnalyticsDictionaryDownloadUseCase(this._analyticsSettingsRepository);

  Future<UseCaseResult<bool>> call(Dictionary argument) async {
    try {
      _analyticsSettingsRepository.logDictionaryDownloadClicked(argument);
    } catch (e, st) {
      _logger.warning(
        'Адбылася памылка пры спробе залагіраваць спампоўку слоўніка `${argument.name}`:',
        e,
        st,
      );
    }
    return const Success(true);
  }
}
