import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart';
import 'package:skarnik_flutter/features/search/domain/use_case/log_analytics_search_no_results.dart';
import 'package:skarnik_flutter/features/search/domain/use_case/log_analytics_search_performed.dart';
import 'package:skarnik_flutter/features/search/domain/use_case/log_analytics_search_result_tapped.dart';
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart';
import 'package:skarnik_flutter/features/search/presentation/search_cubit.dart';

class MockKeyboardVisibilityController extends Mock implements KeyboardVisibilityController {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockWord extends Mock implements SearchWord {}

class MockLogAnalyticsSearchPerformedUseCase extends Mock
    implements LogAnalyticsSearchPerformedUseCase {}

class MockLogAnalyticsSearchNoResultsUseCase extends Mock
    implements LogAnalyticsSearchNoResultsUseCase {}

class MockLogAnalyticsSearchResultTappedUseCase extends Mock
    implements LogAnalyticsSearchResultTappedUseCase {}

void main() {
  group('SearchCubit', () {
    final keyboardController = MockKeyboardVisibilityController();
    final searchRepository = MockSearchRepository();
    final logAnalyticsSearchPerformedUseCase = MockLogAnalyticsSearchPerformedUseCase();
    final logAnalyticsSearchNoResultsUseCase = MockLogAnalyticsSearchNoResultsUseCase();
    final logAnalyticsSearchResultTappedUseCase = MockLogAnalyticsSearchResultTappedUseCase();

    setUpAll(() {
      registerFallbackValue(
        (query: '', resultCount: 0, usedPrepositionFallback: false),
      );
      registerFallbackValue((query: '', usedPrepositionFallback: false));
      registerFallbackValue((word: MockWord(), position: 0, query: ''));
      when(
        () => logAnalyticsSearchPerformedUseCase(any()),
      ).thenAnswer((_) async => const Success(true));
      when(
        () => logAnalyticsSearchNoResultsUseCase(any()),
      ).thenAnswer((_) async => const Success(true));
      when(
        () => logAnalyticsSearchResultTappedUseCase(any()),
      ).thenAnswer((_) async => const Success(true));
    });

    SearchCubit newInstance() => SearchCubit(
      keyboardVisibilityController: keyboardController,
      searchUseCase: SearchUseCase(searchRepository),
      logAnalyticsSearchPerformedUseCase: logAnalyticsSearchPerformedUseCase,
      logAnalyticsSearchNoResultsUseCase: logAnalyticsSearchNoResultsUseCase,
      logAnalyticsSearchResultTappedUseCase: logAnalyticsSearchResultTappedUseCase,
    );

    group('_search()', () {
      late final SearchWord word1;
      late final SearchWord word2;

      blocTest(
        'emits failed state when failed to retrieve words from database',
        setUp: () {
          when(
            () => keyboardController.onChange,
          ).thenAnswer(
            (_) => Stream.value(true),
          );
          when(
            () => searchRepository.search(any()),
          ).thenThrow(
            UnimplementedError('test search error'),
          );
        },
        build: () => newInstance(),
        wait: const Duration(milliseconds: 100),
        act: (cubit) async {
          cubit.searchTextController.text = 'іэя';
        },
        expect: () => [
          isA<SearchKeyboardChangedState>().having((state) => state.isVisible, 'isVisible', isTrue),
          isA<SearchFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test search error'),
          ),
        ],
      );

      blocTest(
        'emits ok state when found words in database',
        setUp: () {
          word1 = MockWord();
          word2 = MockWord();

          when(
            () => keyboardController.onChange,
          ).thenAnswer(
            (_) => Stream.value(true),
          );
          when(
            () => searchRepository.search(any()),
          ).thenAnswer(
            (_) async => (words: [word1, word2], usedPrepositionFallback: false),
          );
        },
        build: () => newInstance(),
        wait: const Duration(milliseconds: 100),
        act: (cubit) async {
          cubit.searchTextController.text = 'аўы';
        },
        expect: () => [
          isA<SearchKeyboardChangedState>().having((state) => state.isVisible, 'isVisible', isTrue),
          isA<SearchLoadedState>()
              .having(
                (state) => state.items,
                'items',
                equals([word1, word2]),
              )
              .having(
                (state) => state.query,
                'query',
                equals('аўы'),
              ),
        ],
      );

      blocTest(
        'forwards usedPrepositionFallback from search results to the analytics use case',
        setUp: () {
          when(
            () => keyboardController.onChange,
          ).thenAnswer(
            (_) => Stream.value(true),
          );
          when(
            () => searchRepository.search(any()),
          ).thenAnswer(
            (_) async => (words: [MockWord()], usedPrepositionFallback: true),
          );
        },
        build: () => newInstance(),
        wait: const Duration(milliseconds: 700),
        act: (cubit) async {
          cubit.searchTextController.text = 'всмысле';
        },
        verify: (_) {
          verify(
            () => logAnalyticsSearchPerformedUseCase(
              (query: 'всмысле', resultCount: 1, usedPrepositionFallback: true),
            ),
          ).called(1);
        },
      );

      test('does not emit after the cubit is closed while a search is in flight', () async {
        final completer = Completer<({Iterable<SearchWord> words, bool usedPrepositionFallback})>();
        when(
          () => keyboardController.onChange,
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => searchRepository.search(any()),
        ).thenAnswer((_) => completer.future);

        final cubit = newInstance();
        cubit.searchTextController.text = 'впику';
        // Let the 50ms rxdart debounce fire so _search() starts awaiting the
        // (still-pending) repository call.
        await Future<void>.delayed(const Duration(milliseconds: 100));

        await cubit.close();
        // Resolving after close() reproduces the race that previously threw
        // "Bad state: Cannot emit new states after calling close".
        completer.complete((words: [MockWord()], usedPrepositionFallback: false));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cubit.state, isNot(isA<SearchLoadedState>()));
      });
    });

    group('search input', () {
      test('append letter with special buttons, clear input', () {
        final cubit = newInstance();
        // Set initial text selection to emulate user focus.
        cubit.searchTextController.selection = TextSelection.fromPosition(
          const TextPosition(offset: 0),
        );
        expect(cubit.searchTextController.text, equals(''));

        cubit.appendLetter('а');
        expect(cubit.searchTextController.text, equals('а'));

        cubit.appendLetter('ў');
        expect(cubit.searchTextController.text, equals('аў'));

        cubit.clearSearch();
        expect(cubit.searchTextController.text, equals(''));
      });
    });
  });
}
