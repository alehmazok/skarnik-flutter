import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class LogAnalyticsAppOpenUseCase extends NoArgsEitherUseCase<bool> {
  final _logger = getLogger(LogAnalyticsAppOpenUseCase);

  LogAnalyticsAppOpenUseCase();

  @override
  Future<Either<Object, bool>> call() async {
    try {
      final analytics = FirebaseAnalytics.instance;
      analytics.logAppOpen();
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе шарынга адкрыцця аплікацыі:', e, st);
    }
    return const Right(true);
  }
}
