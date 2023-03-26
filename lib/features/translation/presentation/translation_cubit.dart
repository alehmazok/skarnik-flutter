import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/core/pair.dart';

import '../domain/entity/translation.dart';
import '../domain/use_case/get_translation.dart';
import '../domain/use_case/get_word.dart';
import '../domain/use_case/save_to_history.dart';

class TranslationState extends Equatable {
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

  const TranslationLoadedState(this.translation);
}

class TranslationCubit extends Cubit<TranslationState> {
  final int langId;
  final int wordId;
  final GetWordUseCase getWordUseCase;
  final GetTranslationUseCase getTranslationUseCase;
  final SaveToHistoryUseCase saveToHistoryUseCase;

  TranslationCubit({
    required this.langId,
    required this.wordId,
    required this.getWordUseCase,
    required this.getTranslationUseCase,
    required this.saveToHistoryUseCase,
  }) : super(const TranslationInProgressState()) {
    _getWord();
  }

  Future<void> _getWord() async {
    final getTranslation = await getWordUseCase(langId, wordId)
        .flatMap(
          (word) => getTranslationUseCase(word).map((translation) => Pair(word, translation)),
        )
        .flatMap(
          (pair) => saveToHistoryUseCase(pair.first).map((_) => pair.second),
        );
    getTranslation.fold(
      (error) => emit(TranslationFailedState(error)),
      (translation) => emit(TranslationLoadedState(translation)),
    );
  }
}
