import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart';
import 'package:skarnik_flutter/logging.dart';

import '../domain/use_case/load_favorites.dart';

abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];

  const FavoritesState();
}

class FavoritesInitedState extends FavoritesState {
  const FavoritesInitedState();
}

class FavoritesFailedState extends FavoritesState {
  final Object error;

  @override
  List<Object> get props => [error];

  const FavoritesFailedState(this.error);
}

class FavoritesRemovedState extends FavoritesState {
  final Word word;

  @override
  List<Object?> get props => [word];

  const FavoritesRemovedState(this.word);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final _logger = getLogger(FavoritesCubit);

  final LoadFavoritesUseCase loadFavoritesUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;
  final pagingController = PagingController<int, Word>(firstPageKey: 0);
  final _candidatesToRemove = <Word, bool>{};

  FavoritesCubit({
    required this.loadFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
  }) : super(const FavoritesInitedState()) {
    _logger.fine('New instance created: $hashCode');
    pagingController.addPageRequestListener(_load);
  }

  Future<void> _load(int offset) async {
    final loadFavorites = await loadFavoritesUseCase(offset);
    loadFavorites.fold(
      (error) => emit(FavoritesFailedState(error)),
      (words) {
        if (words.length < AppConfig.historyWordsPerPageLimit) {
          pagingController.appendLastPage(words.toList());
        } else {
          final nextOffset = AppConfig.historyWordsPerPageLimit + offset;
          pagingController.appendPage(words.toList(), nextOffset);
        }
      },
    );
  }

  void reload() => pagingController.refresh();

  Future<void> cancelRemoval(Word word) async {
    _candidatesToRemove[word] = false;
    reload();
  }

  Future<void> removeFromFavorites(Word word) async {
    _candidatesToRemove[word] = true;
    emitGuarded(FavoritesRemovedState(word));
    await Future.delayed(const Duration(seconds: 4));
    final confirmed = _candidatesToRemove[word] ?? false;
    if (!confirmed) {
      _candidatesToRemove.remove(word);
      return;
    }
    final removeFromFavorites = await removeFromFavoritesUseCase(word);
    switch (removeFromFavorites) {
      case Failure(error: final error):
        emitGuarded(FavoritesFailedState(error));
      case Success():
        _candidatesToRemove.remove(word);
    }
  }

  void emitGuarded(FavoritesState state) {
    if (isClosed) return;
    emit(state);
  }

  @override
  Future<void> close() {
    _logger.fine('Cubit has been closed');
    pagingController.dispose();
    return super.close();
  }
}
