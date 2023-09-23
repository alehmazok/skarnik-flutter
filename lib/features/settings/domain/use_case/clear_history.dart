import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/settings_history_repository.dart';

@injectable
class ClearHistoryUseCase {
  final _logger = getLogger(ClearHistoryUseCase);

  final SettingsHistoryRepository _repository;

  ClearHistoryUseCase(this._repository);

  Future<UseCaseResult<bool>> call() async {
    try {
      final result = await _repository.clear();
      return Success(result);
    } catch (e, st) {
      _logger.severe('Здарылася памылка падчас ачысткі гісторыі пошуку:', e, st);
      return Failure(e);
    }
  }
}
