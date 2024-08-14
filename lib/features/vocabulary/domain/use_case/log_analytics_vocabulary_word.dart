import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/analytics_vocabulary_repository.dart';

@injectable
class LogAnalyticsVocabularyWordUseCase {
  final _logger = getLogger(LogAnalyticsVocabularyWordUseCase);

  final AnalyticsVocabularyRepository _repository;

  LogAnalyticsVocabularyWordUseCase(this._repository);

  Future<UseCaseResult<bool>> call(Word word) async {
    try {
      await _repository.logWord(word);
    } catch (e, st) {
      _logger.warning('Адбылася памылка падчас лагіравання падзеі адкрыцця слова ў слоўніку `$word`:', e, st);
    }
    return const Success(true);
  }
}
