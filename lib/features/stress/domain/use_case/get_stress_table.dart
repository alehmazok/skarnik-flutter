import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';

import '../entity/stress_row.dart';
import '../repository/stress_repository.dart';

@injectable
class GetStressTableUseCase {
  final StressRepository _repository;

  const GetStressTableUseCase(this._repository);

  Future<UseCaseResult<List<StressRow>>> call(int wordId) async {
    try {
      final rows = await _repository.getStressTable(wordId);
      if (rows.isEmpty) return const Failure(null);
      return Success(rows);
    } catch (e, st) {
      return Failure(e, st);
    }
  }
}
