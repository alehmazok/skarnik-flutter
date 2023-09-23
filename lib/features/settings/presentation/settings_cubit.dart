import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';

import '../domain/use_case/clear_history.dart';

sealed class SettingsState extends Equatable {
  const SettingsState() : super();

  @override
  List<Object?> get props => [];
}

class SettingsInitedState extends SettingsState {
  const SettingsInitedState();
}

class SettingsInProgressState extends SettingsState {
  const SettingsInProgressState();
}

class SettingsFailureState extends SettingsState {
  final Object error;

  @override
  List<Object> get props => [error];

  const SettingsFailureState(this.error);
}

class SettingsClearedState extends SettingsState {
  const SettingsClearedState();
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this.clearHistoryUseCase,
  }) : super(const SettingsInitedState());

  final ClearHistoryUseCase clearHistoryUseCase;

  Future<void> clearHistory() async {
    emit(const SettingsInProgressState());
    final clear = await clearHistoryUseCase();
    switch (clear) {
      case Failure(error: final error):
        emit(SettingsFailureState(error));
      case Success():
        emit(const SettingsClearedState());
    }
  }
}
