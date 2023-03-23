import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/logging.dart';

import '../domain/use_case/init_database.dart';

class SkarnikAppState extends Equatable {
  @override
  List<Object> get props => [];

  const SkarnikAppState() : super();
}

class SkarnikAppInitedState extends SkarnikAppState {
  const SkarnikAppInitedState();
}

class SkarnikAppInProgressState extends SkarnikAppState {
  const SkarnikAppInProgressState();
}

class SkarnikAppFailedState extends SkarnikAppState {
  final Object error;

  @override
  List<Object> get props => [error];

  const SkarnikAppFailedState(this.error);
}

class SkarnikAppCubit extends Cubit<SkarnikAppState> {
  final InitDatabaseUseCase initDatabaseUseCase;
  final _logger = getLogger(SkarnikAppCubit);

  SkarnikAppCubit({required this.initDatabaseUseCase}) : super(const SkarnikAppInProgressState()) {
    _init();
  }

  Future<void> _init() async {
    final init = await initDatabaseUseCase();
    init.fold(
      (error) => emit(SkarnikAppFailedState(error)),
      (rows) {
        _logger.fine('База дадзеных паспяхова ініцыялізавана і змяшчае ў сабе $rows слоў.');
        emit(const SkarnikAppInitedState());
      },
    );
  }
}
