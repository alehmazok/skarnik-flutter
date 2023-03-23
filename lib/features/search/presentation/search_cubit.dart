import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:disposebag/disposebag.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:rxdart/transformers.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

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
  final BuiltList<Word> items;

  @override
  List<Object> get props => [items];

  const SearchLoadedState(this.items);

  factory SearchLoadedState.empty() => SearchLoadedState(BuiltList());
}

class SearchKeyboardChangedState extends SearchState {
  final bool isVisible;

  @override
  List<Object> get props => [isVisible];

  const SearchKeyboardChangedState(this.isVisible);
}

class SearchCubit extends Cubit<SearchState> {
  final _logger = getLogger(SearchCubit);

  final SearchUseCase searchUseCase;

  final _bag = DisposeBag();
  final keyboardVisibilityController = KeyboardVisibilityController();
  final searchTextController = TextEditingController();
  final _streamController = StreamController<String>();

  SearchCubit({
    required this.searchUseCase,
  }) : super(const SearchInitedState()) {
    keyboardVisibilityController.onChange.listen(_toggleKeyboard).disposedBy(_bag);

    searchTextController.addListener(() => _streamController.add(searchTextController.text));
    _streamController.stream.debounceTime(const Duration(milliseconds: 50)).listen(_search).disposedBy(_bag);
  }

  void _toggleKeyboard(bool value) => emit(SearchKeyboardChangedState(value));

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      emit(SearchLoadedState.empty());
      return;
    }
    query = query.trim();
    final search = await searchUseCase(query);
    search.fold(
      (error) => emit(SearchFailedState(error)),
      (result) => emit(SearchLoadedState(result.toBuiltList())),
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
    _bag.dispose();
    _streamController.close();
    searchTextController.dispose();

    return super.close();
  }
}
