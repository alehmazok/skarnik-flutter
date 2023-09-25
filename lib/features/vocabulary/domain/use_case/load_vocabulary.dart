import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/vocabulary_repository.dart';

@injectable
class LoadVocabularyUseCase {
  final _logger = getLogger(LoadVocabularyUseCase);

  final VocabularyRepository _repository;

  LoadVocabularyUseCase(this._repository);

  Future<UseCaseResult<Iterable<Word>>> call(int argument) async {
    try {
      final words = await _repository.getWords(argument);
      return Success(words);
    } catch (e, st) {
      _logger.severe('Адбылася памылка атрымання слоўніка ($argument):', e, st);
      return Failure(e);
    }
  }
}
