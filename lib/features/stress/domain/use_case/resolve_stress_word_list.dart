import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';

import '../entity/stress_word_entry.dart';
import '../repository/stress_repository.dart';

@injectable
class ResolveStressWordListUseCase {
  final StressRepository _repository;

  const ResolveStressWordListUseCase(this._repository);

  Future<UseCaseResult<List<StressWordEntry>>> call(String word) async {
    try {
      final words = await _repository.resolveWordList(word);
      final exact = words.where((e) => e.lemma == word).toList();
      if (exact.isEmpty) return const Failure(null);
      return Success(exact);
    } catch (e, st) {
      return Failure(e, st);
    }
  }
}
