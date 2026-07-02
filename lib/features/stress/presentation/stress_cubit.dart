import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';

import '../domain/entity/stress_row.dart';
import '../domain/entity/stress_word_entry.dart';
import '../domain/use_case/get_stress_table.dart';
import '../domain/use_case/log_analytics_stress.dart';
import '../domain/use_case/resolve_stress_word_list.dart';

sealed class StressState extends Equatable {
  @override
  List<Object?> get props => [];
  const StressState();
}

class StressInProgressState extends StressState {
  const StressInProgressState();
}

class StressWordSelectionState extends StressState {
  final List<StressWordEntry> words;

  @override
  List<Object> get props => [words];

  const StressWordSelectionState(this.words);
}

class StressWordSelectedState extends StressState {
  final int wordId;

  /// true → replace current route (single auto-match, no selection to go back to)
  /// false → push new route (user picked from list, selection stays in stack)
  final bool replace;

  @override
  List<Object> get props => [wordId, replace];

  const StressWordSelectedState(this.wordId, {required this.replace});
}

class StressLoadedState extends StressState {
  final List<StressRow> rows;

  @override
  List<Object> get props => [rows];

  const StressLoadedState(this.rows);

  @override
  String toString() => 'StressLoadedState(${rows.length})';
}

class StressFailedState extends StressState {
  final Object error;

  @override
  List<Object> get props => [error];

  const StressFailedState(this.error);
}

class StressNotFoundState extends StressState {
  const StressNotFoundState();
}

class StressCubit extends Cubit<StressState> {
  final String word;
  final LogAnalyticsStressUseCase _logAnalyticsStressUseCase;
  final ResolveStressWordListUseCase _resolveStressWordListUseCase;

  StressCubit({
    required this.word,
    required LogAnalyticsStressUseCase logAnalyticsStressUseCase,
    required ResolveStressWordListUseCase resolveStressWordListUseCase,
  }) : _logAnalyticsStressUseCase = logAnalyticsStressUseCase,
       _resolveStressWordListUseCase = resolveStressWordListUseCase,
       super(const StressInProgressState()) {
    _load();
  }

  Future<void> _load() async {
    unawaited(_logAnalyticsStressUseCase(word));
    final result = await _resolveStressWordListUseCase(word);
    if (isClosed) return;
    switch (result) {
      case Success(result: final words) when words.length == 1:
        emit(StressWordSelectedState(words.first.id, replace: true));
      case Success(result: final words):
        emit(StressWordSelectionState(words));
      case Failure(error: null):
        emit(const StressNotFoundState());
      case Failure(error: final error):
        emit(StressFailedState(error!));
    }
  }

  void selectWord(StressWordEntry entry) {
    final current = state;
    emit(StressWordSelectedState(entry.id, replace: false));
    emit(current);
  }
}

class StressTableCubit extends Cubit<StressState> {
  final GetStressTableUseCase _getStressTableUseCase;

  StressTableCubit({required GetStressTableUseCase getStressTableUseCase})
    : _getStressTableUseCase = getStressTableUseCase,
      super(const StressInProgressState()) {
    // wordId is passed via load(), not constructor, to keep it testable
  }

  Future<void> load(int wordId) async {
    final result = await _getStressTableUseCase(wordId);
    if (isClosed) return;
    switch (result) {
      case Success(result: final rows):
        emit(StressLoadedState(rows));
      case Failure(error: null):
        emit(const StressNotFoundState());
      case Failure(error: final error):
        emit(StressFailedState(error!));
    }
  }
}
