import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';

import '../repository/analytics_stress_repository.dart';

@injectable
class LogAnalyticsStressUseCase {
  final AnalyticsStressRepository _repository;

  const LogAnalyticsStressUseCase(this._repository);

  Future<UseCaseResult<void>> call(String word) async {
    try {
      await _repository.logStressClicked(word);
      return const Success(null);
    } catch (e, st) {
      return Failure(e, st);
    }
  }
}
