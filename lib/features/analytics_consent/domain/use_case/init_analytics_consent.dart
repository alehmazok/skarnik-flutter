import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_consent_repository.dart';

@injectable
class InitAnalyticsConsentUseCase {
  final _logger = getLogger(InitAnalyticsConsentUseCase);

  final AnalyticsConsentRepository _repository;

  InitAnalyticsConsentUseCase(this._repository);

  Future<UseCaseResult<void>> call() async {
    try {
      await _repository.applyStoredConsent();
      return const Success(null);
    } catch (e, st) {
      _logger.severe('Здарылася памылка падчас прымянення згоды на аналітыку:', e, st);
      return Failure(e);
    }
  }
}
