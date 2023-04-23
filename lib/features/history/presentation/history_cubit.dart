import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

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

class HistoryCubit extends Cubit<HistoryState> {
  final _logger = getLogger(HistoryCubit);

  final LoadHistoryUseCase loadHistoryUseCase;
  final pagingController = PagingController<int, Word>(firstPageKey: 0);

  HistoryCubit({
    required this.loadHistoryUseCase,
  }) : super(const HistoryInitedState()) {
    _logger.fine('New instance created: $hashCode');
    pagingController.addPageRequestListener(_load);
  }

  Future<void> _load(int offset) async {
    final loadHistory = await loadHistoryUseCase(offset);
    loadHistory.fold(
      (error) => emit(HistoryFailedState(error)),
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

  @override
  Future<void> close() {
    _logger.fine('Cubit has been closed');
    pagingController.dispose();
    return super.close();
  }
}
