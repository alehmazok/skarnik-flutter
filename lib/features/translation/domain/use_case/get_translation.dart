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

  final PrimaryTranslationRepository _primaryTranslationRepository;
  final FallbackTranslationRepository _fallbackTranslationRepository;

  GetTranslationUseCase({
    required PrimaryTranslationRepository primaryTranslationRepository,
    required FallbackTranslationRepository fallbackTranslationRepository,
  })  : _primaryTranslationRepository = primaryTranslationRepository,
        _fallbackTranslationRepository = fallbackTranslationRepository;

  Future<UseCaseResult<Translation>> call(Word word) => _callPrimary(word);

  Future<UseCaseResult<Translation>> _callPrimary(Word word) async {
    try {
      final translation = await _primaryTranslationRepository.getTranslation(word);
      return Success(translation);
    } catch (e, st) {
      _logger.warning('Адбылася памылка падчас запыту перакладу праз API:', e, st);
      return _callFallback(word);
    }
  }

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
