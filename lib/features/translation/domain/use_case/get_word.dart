import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class GetWordUseCase extends EitherUseCase2<Word, int, int> {
  final _logger = getLogger(GetWordUseCase);

  final WordRepository _wordRepository;

  GetWordUseCase(this._wordRepository);

  @override
  Future<Either<Object, Word>> call(int argument1, int argument2) async {
    try {
      final word = await _wordRepository.getWord(langId: argument1, wordId: argument2);

      if (word == null) {
        return left(StateError('Слова (id=$argument2) не знойдзена ў базе дадзеных.'));
      }

      return right(word);
    } catch (e, st) {
      _logger.severe('Адбылася памылка пры спробе атрымаць слова (id=$argument2) з базы дадзеных:', e, st);

      return left(e);
    }
  }
}
