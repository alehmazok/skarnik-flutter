import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';

import '../entity/stress_row.dart';
import '../entity/stress_source.dart';
import '../repository/cloud_stress_repository.dart';
import '../repository/stress_repository.dart';

@injectable
class GetStressTableUseCase {
  final StressRepository _apiRepository;
  final CloudStressRepository _cloudRepository;

  const GetStressTableUseCase(this._apiRepository, this._cloudRepository);

  // No cross-source retry: wordId is only valid within the source that
  // produced it (Starnik's own numeric IDs vs Supabase's bigint identity
  // are independent id spaces), so a failure here can't fall back to the
  // other source without risking a wrong/mismatched table.
  Future<UseCaseResult<List<StressRow>>> call(int wordId, StressSource source) async {
    try {
      final rows = switch (source) {
        StressSource.api => await _apiRepository.getStressTable(wordId),
        StressSource.cloud => await _cloudRepository.getStressTable(wordId),
      };
      if (rows.isEmpty) return const Failure(null);
      return Success(rows);
    } catch (e, st) {
      return Failure(e, st);
    }
  }
}
