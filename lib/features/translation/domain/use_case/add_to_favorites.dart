import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/favorites_repository.dart';

@injectable
class AddToFavoritesUseCase {
  final _logger = getLogger(AddToFavoritesUseCase);

  final FavoritesRepository _repository;

  AddToFavoritesUseCase(this._repository);

  Future<UseCaseResult<bool>> call(Word word) async {
    try {
      await _repository.add(word);
      return const Success(true);
    } catch (e, st) {
      _logger.severe('Адбылася памылка падчас дадавання слова ў закладкі:', e, st);
      return Failure(e);
    }
  }
}
