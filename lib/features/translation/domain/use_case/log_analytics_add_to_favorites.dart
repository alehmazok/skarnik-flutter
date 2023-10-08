import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_translation_repository.dart';

@injectable
class LogAnalyticsAddToFavoritesUseCase {
  final _logger = getLogger(LogAnalyticsAddToFavoritesUseCase);

  final AnalyticsTranslationRepository _analyticsTranslationRepository;

  LogAnalyticsAddToFavoritesUseCase(this._analyticsTranslationRepository);

  Future<UseCaseResult<bool>> call(Word word) async {
    try {
      _analyticsTranslationRepository.logAddToFavorites(word);
    } catch (e, st) {
      _logger.warning(
        'Адбылася памылка падчас лагавання падзеі дадавання слова `${word.word}` ў закладкі:',
        e,
        st,
      );
    }
    return const Success(true);
  }
}
