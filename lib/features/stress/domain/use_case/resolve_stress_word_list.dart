import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/stress_word_entry.dart';
import '../repository/cloud_stress_repository.dart';
import '../repository/stress_repository.dart';

@injectable
class ResolveStressWordListUseCase {
  final _logger = getLogger(ResolveStressWordListUseCase);

  final StressRepository _apiRepository;
  final CloudStressRepository _cloudRepository;

  ResolveStressWordListUseCase(this._apiRepository, this._cloudRepository);

  Future<UseCaseResult<List<StressWordEntry>>> call(String word) async {
    try {
      final exact = await _resolveExact(_apiRepository.resolveWordList, word);
      if (exact.isNotEmpty) return Success(exact);
    } catch (e, st) {
      _logger.warning('Адбылася памылка падчас пошуку націску праз API:', e, st);
    }

    try {
      final exact = await _resolveExact(_cloudRepository.resolveWordList, word);
      if (exact.isEmpty) return const Failure(null);
      return Success(exact);
    } catch (e, st) {
      return Failure(e, st);
    }
  }

  Future<List<StressWordEntry>> _resolveExact(
    Future<List<StressWordEntry>> Function(String) resolveWordList,
    String word,
  ) async {
    final words = await resolveWordList(word);
    return words.where((e) => e.lemma == word).toList();
  }
}
