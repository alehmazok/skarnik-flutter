import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/vocabulary_repository.dart';

@injectable
class StreamVocabularyUseCase
    extends EitherUseCase1<Stream<Iterable<Word>>, int> {
  final _logger = getLogger(StreamVocabularyUseCase);

  final VocabularyRepository _repository;

  StreamVocabularyUseCase(this._repository);

  @override
  FutureOr<Either<Object, Stream<Iterable<Word>>>> call(int argument) async {
    try {
      final stream = _repository.getStream(argument);
      return right(stream);
    } catch (e, st) {
      _logger.severe('Адбылася памылка атрымання слоўніка ($argument):', e, st);
      return left(e);
    }
  }
}
