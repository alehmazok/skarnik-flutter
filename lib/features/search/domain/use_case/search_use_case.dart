import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/search_repository.dart';

@injectable
class SearchUseCase extends EitherUseCase1<Iterable<Word>, String> {
  final _logger = getLogger(SearchUseCase);

  final SearchRepository _searchRepository;

  SearchUseCase(this._searchRepository);

  @override
  Future<Either<Object, Iterable<Word>>> call(String argument) async {
    try {
      final results = await _searchRepository.search(argument);
      _logger.fine('For query `$argument` found ${results.length} results');

      return right(results);
    } catch (e, st) {
      _logger.severe('An error occurred:', e, st);

      return left(e);
    }
  }
}
