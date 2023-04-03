import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/translation.dart';

@injectable
class LogAnalyticsTranslationUseCase extends EitherUseCase1<bool, Translation> {
  final _logger = getLogger(LogAnalyticsTranslationUseCase);

  LogAnalyticsTranslationUseCase();

  @override
  Future<Either<Object, bool>> call(Translation argument) async {
    try {
      final analytics = FirebaseAnalytics.instance;
      analytics.logEvent(
        name: 'translation',
        parameters: {
          'uri': argument.uri.toString(),
          'word_id': argument.word.wordId,
          'lang_id': argument.word.langId,
        },
      );
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе залагаваць падзею пераклада слова `${argument.word.word}`:', e, st);
    }
    return const Right(true);
  }
}
