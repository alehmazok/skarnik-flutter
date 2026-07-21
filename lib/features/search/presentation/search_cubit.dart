import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:disposebag/disposebag.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:rxdart/transformers.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../domain/use_case/log_analytics_search_no_results.dart';
import '../domain/use_case/log_analytics_search_performed.dart';
import '../domain/use_case/log_analytics_search_result_tapped.dart';
import '../domain/use_case/search_use_case.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];

  const SearchState() : super();
}

class SearchInitedState extends SearchState {
  const SearchInitedState();
}

class SearchFailedState extends SearchState {
  final Object error;

  @override
  List<Object> get props => [error];

  const SearchFailedState(this.error);
}

class SearchLoadedState extends SearchState {
  final String query;
  final BuiltList<SearchWord> items;

  @override
  List<Object> get props => [query, items];

  bool get isNothingFound => query.isNotEmpty && items.isEmpty;

  const SearchLoadedState({
    required this.query,
    required this.items,
  });

  factory SearchLoadedState.empty() => SearchLoadedState(
    query: '',
    items: BuiltList(),
  );

  @override
  String toString() => 'SearchLoadedState(items=${items.length})';
}

class SearchKeyboardChangedState extends SearchState {
  final bool isVisible;

  @override
  List<Object> get props => [isVisible];

  const SearchKeyboardChangedState(this.isVisible);
}

class SearchCubit extends Cubit<SearchState> {
  final _logger = getLogger(SearchCubit);

  final KeyboardVisibilityController keyboardVisibilityController;
  final SearchUseCase searchUseCase;
  final LogAnalyticsSearchPerformedUseCase logAnalyticsSearchPerformedUseCase;
  final LogAnalyticsSearchNoResultsUseCase logAnalyticsSearchNoResultsUseCase;
  final LogAnalyticsSearchResultTappedUseCase logAnalyticsSearchResultTappedUseCase;

  final _bag = DisposeBag();
  final searchTextController = TextEditingController();
  final _streamController = StreamController<String>();
  Timer? _analyticsDebounce;

  SearchCubit({
    required this.keyboardVisibilityController,
    required this.searchUseCase,
    required this.logAnalyticsSearchPerformedUseCase,
    required this.logAnalyticsSearchNoResultsUseCase,
    required this.logAnalyticsSearchResultTappedUseCase,
  }) : super(const SearchInitedState()) {
    keyboardVisibilityController.onChange.listen(_toggleKeyboard).disposedBy(_bag);
    searchTextController.addListener(() => _streamController.add(searchTextController.text));
    _streamController.stream
        .debounceTime(const Duration(milliseconds: 50))
        .listen(_search)
        .disposedBy(_bag);
  }

  void _toggleKeyboard(bool value) => emit(SearchKeyboardChangedState(value));

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      emit(SearchLoadedState.empty());
      return;
    }
    query = query.trim();
    final search = await searchUseCase(query);
    switch (search) {
      case Failure(error: final error):
        emit(SearchFailedState(error));
      case Success(result: final result):
        final items = result.toBuiltList();
        emit(
          SearchLoadedState(
            query: query,
            items: items,
          ),
        );
        _debounceSearchAnalytics(query, items.length);
    }
  }

  void _debounceSearchAnalytics(String query, int resultCount) {
    _analyticsDebounce?.cancel();
    _analyticsDebounce = Timer(const Duration(milliseconds: 500), () {
      if (resultCount > 0) {
        unawaited(logAnalyticsSearchPerformedUseCase((query: query, resultCount: resultCount)));
      } else {
        unawaited(logAnalyticsSearchNoResultsUseCase(query));
      }
    });
  }

  void onResultTapped(SearchWord word, int position, String query) {
    unawaited(
      logAnalyticsSearchResultTappedUseCase((word: word, position: position, query: query)),
    );
  }

  void appendLetter(String letter) {
    final selection = searchTextController.selection;
    final text = searchTextController.text;
    final newText = text.replaceRange(selection.start, selection.end, letter);
    searchTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.baseOffset + letter.length),
    );
  }

  void clearSearch() => searchTextController.clear();

  @override
  Future<void> close() {
    _logger.fine('Cubit has been closed.');
    _analyticsDebounce?.cancel();
    _bag.dispose();
    _streamController.close();
    searchTextController.dispose();

    return super.close();
  }
}
