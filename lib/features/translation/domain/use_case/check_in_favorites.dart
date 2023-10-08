import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/favorites_repository.dart';

@injectable
class CheckInFavoritesUseCase {
  final _logger = getLogger(CheckInFavoritesUseCase);

  final TranslationFavoritesRepository _repository;

  CheckInFavoritesUseCase(this._repository);

  Future<UseCaseResult<bool>> call(Word word) async {
    try {
      final contains = await _repository.contains(word);
      return Success(contains);
    } catch (e, st) {
      _logger.severe('Адбылася памылка пры праверцы слова ў закладках:', e, st);
      return Failure(e);
    }
  }
}
