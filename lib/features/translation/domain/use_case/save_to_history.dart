import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/history_repository.dart';

@injectable
class SaveToHistoryUseCase extends EitherUseCase1<int, Word> {
  final _logger = getLogger(SaveToHistoryUseCase);

  final HistoryRepository _historyRepository;

  SaveToHistoryUseCase(this._historyRepository);

  @override
  Future<Either<Object, int>> call(Word argument) async {
    try {
      final id = await _historyRepository.save(argument);
      return right(id);
    } catch (e, st) {
      _logger.severe('Адбылася памылка пры захаванні слова ў гісторыю:', e, st);
      return left(e);
    }
  }
}
