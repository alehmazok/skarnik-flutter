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

  Future<UseCaseResult<int>> call(Word argument) async {
    try {
      final id = await _repository.add(argument);
      return Success(id);
    } catch (e, st) {
      _logger.severe('Адбылася памылка пры дадаванні слова ў закладкі:', e, st);
      return Failure(e);
    }
  }
}
