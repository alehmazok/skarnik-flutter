import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/favorites_repository.dart';

@injectable
class LoadFavoritesUseCase extends EitherUseCase1<Iterable<Word>, int> {
  final _logger = getLogger(LoadFavoritesUseCase);

  final FavoritesRepository _repository;

  LoadFavoritesUseCase(this._repository);

  @override
  FutureOr<Either<Object, Iterable<Word>>> call(int argument) async {
    try {
      final words = await _repository.getAll(argument);
      return right(words);
    } catch (e, st) {
      _logger.severe('An error occurred:', e, st);
      return left(e);
    }
  }
}
