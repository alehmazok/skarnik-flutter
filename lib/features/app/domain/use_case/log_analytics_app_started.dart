import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_app_repository.dart';

@injectable
class LogAnalyticsAppOpenUseCase extends NoArgsEitherUseCase<bool> {
  final _logger = getLogger(LogAnalyticsAppOpenUseCase);

  final AnalyticsAppRepository _analyticsAppRepository;

  LogAnalyticsAppOpenUseCase(this._analyticsAppRepository);

  @override
  Future<Either<Object, bool>> call() async {
    try {
      _analyticsAppRepository.logAppStarted();
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе залагіраваць падзею адкрыцця аплікацыі:', e, st);
    }
    return const Right(true);
  }
}
