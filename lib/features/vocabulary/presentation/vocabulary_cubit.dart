import 'package:built_collection/built_collection.dart';
import 'package:disposebag/disposebag.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../domain/use_case/load_vocabulary.dart';
import '../domain/use_case/stream_vocabulary.dart';

abstract class VocabularyState extends Equatable {
  @override
  List<Object?> get props => [];

  const VocabularyState() : super();
}

class VocabularyInitedState extends VocabularyState {
  const VocabularyInitedState();
}

class VocabularyFailedState extends VocabularyState {
  final Object error;

  @override
  List<Object> get props => [error];

  const VocabularyFailedState(this.error);
}

class VocabularyLoadedState extends VocabularyState {
  final int langId;
  final BuiltList<Word> words;

  @override
  List<Object> get props => [langId, words];

  const VocabularyLoadedState(this.langId, this.words);

  @override
  String toString() => 'VocabularyLoadedState($langId, ${words.length})';
}

class VocabularyStreamedState extends VocabularyState {
  final int langId;
  final Stream<Iterable<Word>> stream;

  @override
  List<Object> get props => [langId, stream];

  const VocabularyStreamedState(this.langId, this.stream);
}

class VocabularyCubit extends Cubit<VocabularyState> {
  final _logger = getLogger(VocabularyCubit);

  final LoadVocabularyUseCase loadVocabularyUseCase;
  final StreamVocabularyUseCase streamVocabularyUseCase;
  final _disposeBag = DisposeBag();
  final TickerProvider tickerProvider;
  final TabController tabController;
  Map<int, BuiltList<Word>>? _cache;

  VocabularyCubit({
    required this.loadVocabularyUseCase,
    required this.streamVocabularyUseCase,
    required this.tickerProvider,
  })  : tabController = TabController(length: 3, vsync: tickerProvider),
        super(const VocabularyInitedState()) {
    _logger.fine('New instance created: $hashCode');
    loadWords(0);
    tabController.addListener(() {
      _logger.fine('Listener: ${tabController.index}');
      loadWords(tabController.index);
    });
  }

  Future<void> loadWords(int langId) async {
    // await Future.delayed(const Duration(milliseconds: 100));
    emit(const VocabularyInitedState());
    if (_cache?[langId] != null) {
      emit(VocabularyLoadedState(langId, _cache![langId]!));
      return;
    }
    final loadVocabulary = await loadVocabularyUseCase(langId);
    final nextState = loadVocabulary.fold(
      (error) => VocabularyFailedState(error),
      (words) {
        _cache ??= {};
        _cache![langId] = words.toBuiltList();
        return VocabularyLoadedState(langId, words.toBuiltList());
      },
    );
    if (isClosed) return;
    emit(nextState);
  }

  @override
  Future<void> close() {
    _logger.fine('Bloc has been closed: $hashCode');
    _disposeBag.dispose();
    _cache?.clear();
    _cache = null;
    tabController.dispose();
    return super.close();
  }
}
