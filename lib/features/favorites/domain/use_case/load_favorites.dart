import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/favorites_repository.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class LoadFavoritesUseCase {
  final _logger = getLogger(LoadFavoritesUseCase);

  final FavoritesRepository _repository;

  LoadFavoritesUseCase(this._repository);

  FutureOr<UseCaseResult<Iterable<Word>>> call(int argument) async {
    try {
      final words = await _repository.getAll(argument);
      return Success(words);
    } catch (e, st) {
      _logger.severe('An error occurred:', e, st);
      return Failure(e);
    }
  }
}
