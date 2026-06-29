import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';

import '../domain/entity/stress_row.dart';
import '../domain/use_case/get_stress_table.dart';
import '../domain/use_case/log_analytics_stress.dart';

sealed class StressState extends Equatable {
  @override
  List<Object?> get props => [];
  const StressState();
}

class StressInProgressState extends StressState {
  const StressInProgressState();
}

class StressLoadedState extends StressState {
  final List<StressRow> rows;

  @override
  List<Object> get props => [rows];

  const StressLoadedState(this.rows);
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
  final GetStressTableUseCase _getStressTableUseCase;
  final LogAnalyticsStressUseCase _logAnalyticsStressUseCase;

  StressCubit({
    required this.word,
    required GetStressTableUseCase getStressTableUseCase,
    required LogAnalyticsStressUseCase logAnalyticsStressUseCase,
  }) : _getStressTableUseCase = getStressTableUseCase,
       _logAnalyticsStressUseCase = logAnalyticsStressUseCase,
       super(const StressInProgressState()) {
    _load();
  }

  Future<void> _load() async {
    unawaited(_logAnalyticsStressUseCase(word));
    final result = await _getStressTableUseCase(word);
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
