import 'package:disposebag/disposebag.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../domain/entity/word.dart';
import '../domain/use_case/get_app_link_stream.dart';
import '../domain/use_case/handle_app_link.dart';
import '../domain/use_case/init_database.dart';
import '../domain/use_case/init_remote_config.dart';
import '../domain/use_case/log_analytics_app_started.dart';

// Events
abstract class SkarnikAppEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const SkarnikAppEvent() : super();
}

class SkarnikAppStarted extends SkarnikAppEvent {
  const SkarnikAppStarted();
}

class SkarnikAppHistoryUpdated extends SkarnikAppEvent {
  final Word word;

  @override
  List<Object> get props => [];

  const SkarnikAppHistoryUpdated(this.word);
}

class SkarnikAppAppLinkReceived extends SkarnikAppEvent {
  final String appLink;

  @override
  List<Object> get props => [appLink];

  const SkarnikAppAppLinkReceived(this.appLink);
}

// States
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

class SkarnikAppHistoryUpdatedState extends SkarnikAppState {
  final Word word;

  @override
  List<Object> get props => [word.wordId];

  const SkarnikAppHistoryUpdatedState(this.word);
}

class SkarnikAppAppLinkReceivedState extends SkarnikAppState {
  final int langId;
  final int wordId;

  @override
  List<Object> get props => [
        langId,
        wordId,
      ];

  const SkarnikAppAppLinkReceivedState({
    required this.langId,
    required this.wordId,
  });
}

class SkarnikAppBloc extends Bloc<SkarnikAppEvent, SkarnikAppState> {
  final _logger = getLogger(SkarnikAppBloc);
  final _disposeBag = DisposeBag();

  final InitDatabaseUseCase initDatabaseUseCase;
  final InitRemoteConfigUseCase initRemoteConfigUseCase;
  final GetAppLinkStreamUseCase getAppLinkStreamUseCase;
  final HandleAppLinkUseCase handleAppLinkUseCase;
  final LogAnalyticsAppOpenUseCase logAnalyticsAppOpenUseCase;

  SkarnikAppBloc({
    required this.initDatabaseUseCase,
    required this.initRemoteConfigUseCase,
    required this.getAppLinkStreamUseCase,
    required this.handleAppLinkUseCase,
    required this.logAnalyticsAppOpenUseCase,
  }) : super(const SkarnikAppInProgressState()) {
    on<SkarnikAppStarted>(_init);
    on<SkarnikAppHistoryUpdated>(_updateHistory);
    on<SkarnikAppAppLinkReceived>(_handleAppLink);
    add(const SkarnikAppStarted());
  }

  Future<void> _init(SkarnikAppStarted event, Emitter<SkarnikAppState> emit) async {
    final init = await initRemoteConfigUseCase()
        .flatMap(
          (_) => initDatabaseUseCase(),
        )
        .flatMap(
          (rowsCount) => logAnalyticsAppOpenUseCase().map((_) => rowsCount),
        );
    switch (init) {
      case Failure(error: final error):
        emit(SkarnikAppFailedState(error));
      case Success(result: final rows):
        _logger.fine('Remote config паспяхова ініцыялізаваны.');
        _logger.fine('База дадзеных паспяхова ініцыялізавана і змяшчае ў сабе $rows слоў.');
        emit(const SkarnikAppInitedState());
        _listenAppLinks();
    }
  }

  Future<void> _listenAppLinks() async {
    final appLinks = await getAppLinkStreamUseCase();
    switch (appLinks) {
      case Success(result: final stream):
        stream.listen((appLink) => add(SkarnikAppAppLinkReceived(appLink))).disposedBy(_disposeBag);
      case _:
      // Ніяк не рэагуем на памылку, яна ўжо залагавана ў usecase.
    }
  }

  Future<void> _handleAppLink(SkarnikAppAppLinkReceived event, Emitter<SkarnikAppState> emit) async {
    final appLink = event.appLink;
    final handle = await handleAppLinkUseCase(appLink);
    switch (handle) {
      case Success(result: final pair):
        emit(
          SkarnikAppAppLinkReceivedState(
            langId: pair.langId,
            wordId: pair.wordId,
          ),
        );
      case _:
      // Ніяк не рэагуем на памылку, яна ўжо залагавана ў usecase.
    }
  }

  void _updateHistory(SkarnikAppHistoryUpdated event, Emitter<SkarnikAppState> emit) =>
      emit(SkarnikAppHistoryUpdatedState(event.word));

  @override
  Future<void> close() {
    _disposeBag.dispose();
    return super.close();
  }
}
