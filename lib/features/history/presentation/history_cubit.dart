import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../domain/use_case/load_history.dart';

abstract class HistoryState extends Equatable {
  @override
  List<Object?> get props => [];

  const HistoryState();
}

class HistoryInitedState extends HistoryState {
  const HistoryInitedState();
}

class HistoryFailedState extends HistoryState {
  final Object error;

  @override
  List<Object> get props => [error];

  const HistoryFailedState(this.error);
}

class HistoryLoadedState extends HistoryState {
  final BuiltList<Word> words;

  @override
  List<Object> get props => [words];

  const HistoryLoadedState(this.words);
}

class HistoryCubit extends Cubit<HistoryState> {
  final LoadHistoryUseCase loadHistoryUseCase;

  HistoryCubit({
    required this.loadHistoryUseCase,
  }) : super(const HistoryInitedState()) {
    _load();
  }

  Future<void> _load() async {
    final loadHistory = await loadHistoryUseCase();
    loadHistory.fold(
      (error) => emit(HistoryFailedState(error)),
      (words) => emit(HistoryLoadedState(words.toBuiltList())),
    );
  }
}
