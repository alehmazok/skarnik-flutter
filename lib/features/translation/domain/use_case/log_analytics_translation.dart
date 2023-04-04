import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/translation.dart';
import '../repository/analytics_translation_repository.dart';

@injectable
class LogAnalyticsTranslationUseCase extends EitherUseCase1<bool, Translation> {
  final _logger = getLogger(LogAnalyticsTranslationUseCase);

  final AnalyticsTranslationRepository _analyticsTranslationRepository;

  LogAnalyticsTranslationUseCase(this._analyticsTranslationRepository);

  @override
  Future<Either<Object, bool>> call(Translation argument) async {
    try {
      _analyticsTranslationRepository.logTranslation(argument);
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе залагіраваць падзею пераклада слова `${argument.word.word}`:', e, st);
    }
    return const Right(true);
  }
}
