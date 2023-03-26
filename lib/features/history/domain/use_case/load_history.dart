import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/history_repository.dart';

@injectable
class LoadHistoryUseCase extends NoArgsEitherUseCase<Iterable<Word>> {
  final _logger = getLogger(LoadHistoryUseCase);

  final HistoryRepository _historyRepository;

  LoadHistoryUseCase(this._historyRepository);

  @override
  FutureOr<Either<Object, Iterable<Word>>> call() async {
    try {
      final words = await _historyRepository.getAll();
      return right(words);
    } catch (e, st) {
      _logger.severe('An error occurred:', e, st);
      return left(e);
    }
  }
}
