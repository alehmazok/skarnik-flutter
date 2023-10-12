import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../domain/entity/translation.dart';
import '../domain/use_case/add_to_favorites.dart';
import '../domain/use_case/check_in_favorites.dart';
import '../domain/use_case/get_translation.dart';
import '../domain/use_case/get_word.dart';
import '../domain/use_case/log_analytics_add_to_favorites.dart';
import '../domain/use_case/log_analytics_share.dart';
import '../domain/use_case/log_analytics_translation.dart';
import '../domain/use_case/remove_from_favorites.dart';
import '../domain/use_case/save_to_history.dart';

sealed class TranslationState extends Equatable {
  @override
  List<Object?> get props => [];

  const TranslationState() : super();
}

class TranslationInProgressState extends TranslationState {
  const TranslationInProgressState();
}

class TranslationFailedState extends TranslationState {
  final Object error;

  @override
  List<Object> get props => [error];

  const TranslationFailedState(this.error);
}

class TranslationLoadedState extends TranslationState {
  final Translation translation;

  @override
  List<Object> get props => [translation];

  const TranslationLoadedState({
    required this.translation,
  });

  @override
  String toString() => 'TranslationLoadedState(uri=${translation.uri})';
}

class TranslationRemovedFromFavoritesState extends TranslationState {
  const TranslationRemovedFromFavoritesState() : super();
}

class TranslationAddedToFavoritesState extends TranslationState {
  const TranslationAddedToFavoritesState();
}

class TranslationInFavoritesState extends TranslationState {
  final Word word;
  final bool inFavorites;

  @override
  List<Object> get props => [word, inFavorites];

  const TranslationInFavoritesState({
    required this.word,
    required this.inFavorites,
  });
}

class TranslationCubit extends Cubit<TranslationState> {
  final int langId;
  final int wordId;
  final bool saveToHistory;
  final GetWordUseCase getWordUseCase;
  final GetTranslationUseCase getTranslationUseCase;
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final CheckInFavoritesUseCase checkInFavoritesUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;
  final SaveToHistoryUseCase saveToHistoryUseCase;
  final LogAnalyticsShareUseCase logAnalyticsShareUseCase;
  final LogAnalyticsTranslationUseCase logAnalyticsTranslationUseCase;
  final LogAnalyticsAddToFavoritesUseCase logAnalyticsAddToFavoritesUseCase;

  TranslationCubit({
    required this.langId,
    required this.wordId,
    required this.saveToHistory,
    required this.getWordUseCase,
    required this.getTranslationUseCase,
    required this.addToFavoritesUseCase,
    required this.checkInFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
    required this.saveToHistoryUseCase,
    required this.logAnalyticsShareUseCase,
    required this.logAnalyticsTranslationUseCase,
    required this.logAnalyticsAddToFavoritesUseCase,
  }) : super(const TranslationInProgressState()) {
    _getWord();
  }

  Future<void> _getWord() async {
    final getTranslation = await getWordUseCase(
      langId: langId,
      wordId: wordId,
    )
        .flatMap(
      (word) => getTranslationUseCase(word).map(
        (translation) => (word, translation),
      ),
    )
        .flatMap(
      (record) {
        final (word, translation) = record;
        return checkInFavoritesUseCase(word).map((inFavorites) => (word, translation, inFavorites));
      },
    ).flatMap(
      (record) {
        final (word, translation, inFavorites) = record;
        if (saveToHistory) {
          return saveToHistoryUseCase(word).map((_) => (translation, inFavorites));
        }
        return Future.value(Success((translation, inFavorites)));
      },
    ).flatMap(
      (record) {
        final (translation, inFavorites) = record;
        return logAnalyticsTranslationUseCase(translation).map((_) => (translation, inFavorites));
      },
    );
    switch (getTranslation) {
      case Failure(error: final error):
        emitGuarded(TranslationFailedState(error));
      case Success(result: (final translation, final inFavorites)):
        emitGuarded(TranslationLoadedState(translation: translation));
        emitGuarded(
          TranslationInFavoritesState(
            word: translation.word,
            inFavorites: inFavorites,
          ),
        );
    }
  }

  Future<void> share(Translation translation) async {
    final link = translation.shareUri.toString();
    await Share.share(link, subject: translation.word.word);
    // Не апрацоўваць вынік выканання usecase-а.
    await logAnalyticsShareUseCase(link);
  }

  Future<void> addToFavorites(Word word) async {
    final addToFavorites = await addToFavoritesUseCase(word).flatMap(
      (_) => logAnalyticsAddToFavoritesUseCase(word),
    );
    switch (addToFavorites) {
      case Failure(error: final error):
        emitGuarded(TranslationFailedState(error));
      case Success():
        emitGuarded(const TranslationAddedToFavoritesState());
        emitGuarded(
          TranslationInFavoritesState(
            word: word,
            inFavorites: true,
          ),
        );
    }
  }

  Future<void> removeFromFavorites(Word word) async {
    final removeFromFavorites = await removeFromFavoritesUseCase(word);
    switch (removeFromFavorites) {
      case Failure(error: final error):
        emitGuarded(TranslationFailedState(error));
      case Success():
        emitGuarded(const TranslationRemovedFromFavoritesState());
        emitGuarded(
          TranslationInFavoritesState(
            word: word,
            inFavorites: false,
          ),
        );
    }
  }

  void emitGuarded(TranslationState state) {
    if (isClosed) return;
    emit(state);
  }
}
