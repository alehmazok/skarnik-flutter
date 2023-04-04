import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/translation.dart';
import '../repository/analytics_translation_repository.dart';

@injectable
class LogAnalyticsShareUseCase extends EitherUseCase1<bool, Translation> {
  final _logger = getLogger(LogAnalyticsShareUseCase);

  final AnalyticsTranslationRepository _analyticsTranslationRepository;

  LogAnalyticsShareUseCase(this._analyticsTranslationRepository);

  @override
  Future<Either<Object, bool>> call(Translation argument) async {
    try {
      _analyticsTranslationRepository.logShare(argument);
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе залагіраваць падзею шарынга слова `${argument.word.word}`:', e, st);
    }
    return const Right(true);
  }
}
