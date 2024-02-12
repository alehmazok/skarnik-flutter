import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class LoadHistoryUseCase {
  final _logger = getLogger(LoadHistoryUseCase);

  final HistoryRepository _historyRepository;

  LoadHistoryUseCase(this._historyRepository);

  FutureOr<UseCaseResult<Iterable<Word>>> call(int argument) async {
    try {
      final words = await _historyRepository.getAll(argument);
      return Success(words);
    } catch (e, st) {
      _logger.severe('An error occurred while loading history:', e, st);
      return Failure(e);
    }
  }
}
