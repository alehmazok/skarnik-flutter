import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_app_repository.dart';

@injectable
class LogAnalyticsAppOpenUseCase {
  final _logger = getLogger(LogAnalyticsAppOpenUseCase);

  final AnalyticsAppRepository _analyticsAppRepository;

  LogAnalyticsAppOpenUseCase(this._analyticsAppRepository);

  Future<UseCaseResult<bool>> call() async {
    try {
      _analyticsAppRepository.logAppStarted();
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе залагіраваць падзею адкрыцця аплікацыі:', e, st);
    }
    return const Success(true);
  }
}
