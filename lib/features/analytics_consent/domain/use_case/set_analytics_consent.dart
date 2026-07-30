import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_consent_repository.dart';

@injectable
class SetAnalyticsConsentUseCase {
  final _logger = getLogger(SetAnalyticsConsentUseCase);

  final AnalyticsConsentRepository _repository;

  SetAnalyticsConsentUseCase(this._repository);

  Future<UseCaseResult<void>> call(bool granted) async {
    try {
      await _repository.setConsent(granted);
      return const Success(null);
    } catch (e, st) {
      _logger.severe('Здарылася памылка падчас захавання згоды на аналітыку:', e, st);
      return Failure(e);
    }
  }
}
