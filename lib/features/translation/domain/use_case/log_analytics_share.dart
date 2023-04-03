import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/translation.dart';

@injectable
class LogAnalyticsShareUseCase extends EitherUseCase1<bool, Translation> {
  final _logger = getLogger(LogAnalyticsShareUseCase);

  LogAnalyticsShareUseCase();

  @override
  Future<Either<Object, bool>> call(Translation argument) async {
    try {
      final analytics = FirebaseAnalytics.instance;
      analytics.logShare(
        contentType: ContentType.text.mimeType,
        itemId: argument.uri.toString(),
        method: 'system',
      );
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе залагаваць падзею шарынга слова `${argument.word.word}`:', e, st);
    }
    return const Right(true);
  }
}
