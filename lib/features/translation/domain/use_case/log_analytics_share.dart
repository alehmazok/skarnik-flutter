import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_translation_repository.dart';

@injectable
class LogAnalyticsShareUseCase {
  final _logger = getLogger(LogAnalyticsShareUseCase);

  final AnalyticsTranslationRepository _analyticsTranslationRepository;

  LogAnalyticsShareUseCase(this._analyticsTranslationRepository);

  Future<UseCaseResult<bool>> call(String link) async {
    try {
      await _analyticsTranslationRepository.logShare(link);
    } catch (e, st) {
      _logger.warning('Адбылася памылка падчас лагавання падзеі шарынга спасылкі `$link`:', e, st);
    }
    return const Success(true);
  }
}
