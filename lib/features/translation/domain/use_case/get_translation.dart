import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/translation.dart';
import '../repository/translation_repository.dart';

@injectable
class GetTranslationUseCase extends EitherUseCase1<Translation, Word> {
  final _logger = getLogger(GetTranslationUseCase);

  final TranslationRepository _translationRepository;

  GetTranslationUseCase(this._translationRepository);

  @override
  Future<Either<Object, Translation>> call(Word argument) async {
    try {
      final translation = await _translationRepository.getTranslation(argument);

      _logger.fine(translation.html);

      return right(translation);
    } catch (e, st) {
      _logger.severe('Адбылася памылка падчас запыту перакладу:', e, st);

      return left(e);
    }
  }
}
