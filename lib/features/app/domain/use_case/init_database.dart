import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/repository/database_repository.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class InitDatabaseUseCase extends NoArgsEitherUseCase<int> {
  final _logger = getLogger(InitDatabaseUseCase);

  final DatabaseRepository _databaseRepository;

  InitDatabaseUseCase(this._databaseRepository);

  @override
  FutureOr<Either<Object, int>> call() async {
    try {
      final result = await _databaseRepository.createDatabase();

      return right(result);
    } catch (e, st) {
      _logger.severe('An error occurred:', e, st);

      return left(e);
    }
  }
}
