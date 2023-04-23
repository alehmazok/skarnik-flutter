import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/vocabulary_repository.dart';

@injectable
class LoadVocabularyUseCase extends EitherUseCase1<Iterable<Word>, int> {
  final _logger = getLogger(LoadVocabularyUseCase);

  final VocabularyRepository _repository;

  LoadVocabularyUseCase(this._repository);

  @override
  FutureOr<Either<Object, Iterable<Word>>> call(int argument) async {
    try {
      final words = await _repository.getWords(argument);
      return right(words);
    } catch (e, st) {
      _logger.severe('Адбылася памылка атрымання слоўніка ($argument):', e, st);
      return left(e);
    }
  }
}

@pragma('vm:entry-point')
Future<Iterable<Word>> expensiveWork(int arg) async {
  configureDependencies(kDebugMode ? 'dev' : 'prod');
  final repository = getIt<VocabularyRepository>();
  final words = await repository.getWords(arg);
  return words;
}
