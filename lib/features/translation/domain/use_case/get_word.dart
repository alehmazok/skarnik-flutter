import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class GetWordUseCase {
  final _logger = getLogger(GetWordUseCase);

  final WordRepository _wordRepository;

  GetWordUseCase(this._wordRepository);

  Future<UseCaseResult<Word>> call({
    required int langId,
    required int wordId,
  }) async {
    try {
      final word = await _wordRepository.getWord(langId: langId, wordId: wordId);

      if (word == null) {
        return Failure(StateError('Слова (id=$wordId) не знойдзена ў базе дадзеных.'));
      }

      return Success(word);
    } catch (e, st) {
      _logger.severe('Адбылася памылка пры спробе атрымаць слова (id=$wordId) з базы дадзеных:', e, st);

      return Failure(e);
    }
  }
}
