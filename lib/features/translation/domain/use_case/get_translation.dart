import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/translation.dart';
import '../repository/translation_repository.dart';

@injectable
class GetTranslationUseCase {
  final _logger = getLogger(GetTranslationUseCase);

  final FallbackTranslationRepository _fallbackTranslationRepository;

  GetTranslationUseCase(
    this._fallbackTranslationRepository,
  );

  Future<UseCaseResult<Translation>> call(Word word) => _callFallback(word);

  Future<UseCaseResult<Translation>> _callFallback(Word word) async {
    try {
      final translation = await _fallbackTranslationRepository.getTranslation(word);
      return Success(translation);
    } catch (e, st) {
      _logger.severe('Адбылася памылка падчас запыту перакладу праз сайт:', e, st);
      return Failure(e);
    }
  }
}
