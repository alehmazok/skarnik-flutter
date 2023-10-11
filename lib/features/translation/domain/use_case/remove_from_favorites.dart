import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/favorites_repository.dart';

@injectable
class RemoveFromFavoritesUseCase {
  final _logger = getLogger(RemoveFromFavoritesUseCase);

  final FavoritesRepository _repository;

  RemoveFromFavoritesUseCase(this._repository);

  Future<UseCaseResult<bool>> call(Word word) async {
    try {
      final removed = await _repository.remove(word);
      return Success(removed);
    } catch (e, st) {
      _logger.severe('Адбылася памылка падчас выдалення слова з закладак:', e, st);
      return Failure(e);
    }
  }
}
