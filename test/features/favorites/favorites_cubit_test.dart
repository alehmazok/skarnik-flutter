import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/favorites/domain/use_case/load_favorites.dart';
import 'package:skarnik_flutter/features/favorites/presentation/favorites_cubit.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/favorites_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockWord extends Mock implements Word {}

void main() {
  group('FavoritesCubit', () {
    final favoritesRepository = MockFavoritesRepository();

    FavoritesCubit newInstance() => FavoritesCubit(
          loadFavoritesUseCase: LoadFavoritesUseCase(favoritesRepository),
          removeFromFavoritesUseCase: RemoveFromFavoritesUseCase(favoritesRepository),
        );

    group('_load()', () {
      late final Word word;

      blocTest(
        'emits failed state when failed to retrieve words from database',
        setUp: () {
          when(
            () => favoritesRepository.getAll(any()),
          ).thenThrow(
            UnimplementedError('test error'),
          );
        },
        build: () => newInstance(),
        act: (cubit) => cubit.pagingController.notifyPageRequestListeners(0),
        expect: () => [
          isA<FavoritesFailedState>(),
        ],
      );

      blocTest(
        'emits ok state when successfully retrieved words from database',
        setUp: () {
          word = MockWord();
          when(
            () => favoritesRepository.getAll(any()),
          ).thenAnswer(
            (_) async => [word],
          );
        },
        build: () => newInstance(),
        act: (cubit) => cubit.pagingController.notifyPageRequestListeners(0),
        expect: () => [],
        verify: (cubit) {
          final items = cubit.pagingController.itemList;
          expect(items?.length, equals(1));
          expect(items, equals([word]));
        },
      );
    });

    group('removeFromFavorites()', () {
      late final Word word1;
      late final Word word2;

      setUpAll(() {
        word1 = MockWord();
        word2 = MockWord();

        when(
          () => favoritesRepository.getAll(any()),
        ).thenAnswer(
          (_) async => [word1, word2],
        );
      });

      blocTest(
        'emits failed state when failed to remove from favorites',
        setUp: () {
          when(
            () => favoritesRepository.remove(word1),
          ).thenThrow(UnimplementedError('test remove error'));
        },
        build: () => newInstance(),
        act: (cubit) {
          cubit.pagingController.notifyPageRequestListeners(0);
          cubit.removeFromFavorites(word1);
        },
        wait: const Duration(seconds: 4),
        expect: () => [
          isA<FavoritesRemovedState>().having((state) => state.word, 'word', equals(word1)),
          isA<FavoritesFailedState>(),
        ],
        verify: (cubit) async {
          verify(() => favoritesRepository.remove(word1)).called(1);
        },
      );

      blocTest(
        'emits ok state when successfully removed from favorites',
        setUp: () {
          when(
            () => favoritesRepository.remove(word1),
          ).thenAnswer((_) async => true);
        },
        build: () => newInstance(),
        act: (cubit) {
          cubit.pagingController.notifyPageRequestListeners(0);
          cubit.removeFromFavorites(word1);
        },
        wait: const Duration(seconds: 4),
        expect: () => [
          isA<FavoritesRemovedState>().having((state) => state.word, 'word', equals(word1)),
        ],
        verify: (cubit) async {
          verify(() => favoritesRepository.remove(word1)).called(1);
        },
      );

      blocTest(
        'emits ok state when user cancel removal from favorites',
        build: () => newInstance(),
        act: (cubit) {
          cubit.pagingController.notifyPageRequestListeners(0);
          cubit.removeFromFavorites(word1);
          cubit.cancelRemoval(word1);
        },
        wait: const Duration(seconds: 4),
        expect: () => [
          isA<FavoritesRemovedState>().having((state) => state.word, 'word', equals(word1)),
        ],
        verify: (cubit) async {
          verifyNever(() => favoritesRepository.remove(word1));
        },
      );
    });
  });
}
