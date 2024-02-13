import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart';
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart';
import 'package:skarnik_flutter/features/search/presentation/search_cubit.dart';

class MockKeyboardVisibilityController extends Mock implements KeyboardVisibilityController {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockWord extends Mock implements Word {}

void main() {
  group('SearchCubit', () {
    final keyboardController = MockKeyboardVisibilityController();
    final searchRepository = MockSearchRepository();

    SearchCubit newInstance() => SearchCubit(
          keyboardVisibilityController: keyboardController,
          searchUseCase: SearchUseCase(searchRepository),
        );

    group('_search()', () {
      late final Word word1;
      late final Word word2;

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
            (_) async => [word1, word2],
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
    });

    group('search input', () {
      test('append letter with special buttons, clear input', () {
        final cubit = newInstance();
        // Set initial text selection to emulate user focus.
        cubit.searchTextController.selection = TextSelection.fromPosition(const TextPosition(offset: 0));
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
