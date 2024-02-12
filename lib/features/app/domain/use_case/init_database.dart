import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/database_repository.dart';

@injectable
class InitDatabaseUseCase {
  final _logger = getLogger(InitDatabaseUseCase);

  final DatabaseRepository _databaseRepository;

  InitDatabaseUseCase(this._databaseRepository);

  Future<UseCaseResult<int>> call() async {
    try {
      final result = await _databaseRepository.createDatabase();

      return Success(result);
    } catch (e, st) {
      _logger.severe('An error occurred:', e, st);

      return Failure(e);
    }
  }
}
