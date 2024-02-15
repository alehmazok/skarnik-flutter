import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/analytics_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/favorites_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/add_to_favorites.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/check_in_favorites.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/get_word.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_add_to_favorites.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_share.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_translation.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/save_to_history.dart';
import 'package:skarnik_flutter/features/translation/presentation/translation_cubit.dart';

class MockWordRepository extends Mock implements WordRepository {}

class MockFallbackTranslationRepository extends Mock implements FallbackTranslationRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockAnalyticsTranslationRepository extends Mock implements AnalyticsTranslationRepository {}

class MockWord extends Mock implements Word {}

void main() {
  group('TranslationCubit', () {
    final wordRepository = MockWordRepository();
    final translationRepository = MockFallbackTranslationRepository();
    final favoritesRepository = MockFavoritesRepository();
    final historyRepository = MockHistoryRepository();
    final analyticsTranslationRepository = MockAnalyticsTranslationRepository();

    TranslationCubit newInstance({bool saveToHistory = true}) => TranslationCubit(
          langId: 1,
          wordId: 1,
          saveToHistory: saveToHistory,
          getWordUseCase: GetWordUseCase(wordRepository),
          getTranslationUseCase: GetTranslationUseCase(translationRepository),
          addToFavoritesUseCase: AddToFavoritesUseCase(favoritesRepository),
          checkInFavoritesUseCase: CheckInFavoritesUseCase(favoritesRepository),
          removeFromFavoritesUseCase: RemoveFromFavoritesUseCase(favoritesRepository),
          saveToHistoryUseCase: SaveToHistoryUseCase(historyRepository),
          logAnalyticsTranslationUseCase: LogAnalyticsTranslationUseCase(analyticsTranslationRepository),
          logAnalyticsAddToFavoritesUseCase: LogAnalyticsAddToFavoritesUseCase(analyticsTranslationRepository),
          logAnalyticsShareUseCase: LogAnalyticsShareUseCase(analyticsTranslationRepository),
        );

    group('_getWord()', () {
      late final Word word;
      blocTest(
        'emits failed state when failed to retrieve the word from database',
        setUp: () {
          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenThrow(
            UnimplementedError('test get word error'),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<TranslationFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test get word error'),
          ),
        ],
      );

      blocTest(
        'emits failed state when failed to get translation',
        setUp: () {
          final word = MockWord();

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenThrow(
            UnimplementedError('test translation error'),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<TranslationFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test translation error'),
          ),
        ],
      );

      blocTest(
        'emits failed state when failed to check the word is in favorites',
        setUp: () {
          final word = MockWord();

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => Translation.build(
              word: word,
              html: '<div>test</div>',
              uri: Uri.parse('https://skarnik.by/word/test'),
            ),
          );

          when(
            () => favoritesRepository.contains(word),
          ).thenThrow(
            UnimplementedError('test favorites error'),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<TranslationFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test favorites error'),
          ),
        ],
      );

      blocTest(
        'emits failed state when failed to save the word in history',
        setUp: () {
          final word = MockWord();

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => Translation.build(
              word: word,
              html: '<div>test</div>',
              uri: Uri.parse('https://skarnik.by/word/test'),
            ),
          );

          when(
            () => favoritesRepository.contains(word),
          ).thenAnswer(
            (_) async => false,
          );

          when(
            () => historyRepository.save(word),
          ).thenThrow(
            UnimplementedError('test history error'),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<TranslationFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test history error'),
          ),
        ],
      );

      blocTest(
        'emits ok state when failed to log analytics event',
        setUp: () {
          final word = MockWord();
          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: Uri.parse('https://skarnik.by/word/test'),
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => translation,
          );

          when(
            () => favoritesRepository.contains(word),
          ).thenAnswer(
            (_) async => false,
          );

          when(
            () => historyRepository.save(word),
          ).thenAnswer(
            (_) async => 1,
          );

          when(
            () => analyticsTranslationRepository.logTranslation(translation),
          ).thenThrow(
            UnimplementedError('test analytics error'),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<TranslationLoadedState>().having(
            (state) => state.translation.word.word,
            'word',
            equals('word 1'),
          ),
          isA<TranslationInFavoritesState>(),
        ],
      );

      blocTest(
        'not saving to history when saveToHistory=false passed',
        setUp: () {
          word = MockWord();
          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: Uri.parse('https://skarnik.by/word/test'),
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => translation,
          );

          when(
            () => favoritesRepository.contains(word),
          ).thenAnswer(
            (_) async => false,
          );

          when(
            () => historyRepository.save(word),
          ).thenAnswer(
            (_) async => 1,
          );

          when(
            () => analyticsTranslationRepository.logTranslation(translation),
          ).thenAnswer(
            (_) async => true,
          );
        },
        build: () => newInstance(saveToHistory: false),
        expect: () => [
          isA<TranslationLoadedState>().having(
            (state) => state.translation.word.word,
            'word',
            equals('word 1'),
          ),
          isA<TranslationInFavoritesState>(),
        ],
        verify: (_) {
          verifyNever(() => historyRepository.save(word));
        },
      );
    });

    group('addToFavorites()', () {
      late Word word;

      blocTest(
        'emits failed state when saving to favorites',
        setUp: () {
          word = MockWord();
          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: Uri.parse('https://skarnik.by/word/test'),
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => translation,
          );

          when(
            () => favoritesRepository.contains(word),
          ).thenAnswer(
            (_) async => false,
          );

          when(
            () => historyRepository.save(word),
          ).thenAnswer(
            (_) async => 1,
          );

          when(
            () => analyticsTranslationRepository.logTranslation(translation),
          ).thenAnswer(
            (_) async => true,
          );

          when(
            () => favoritesRepository.add(word),
          ).thenThrow(
            UnimplementedError('test add to favorites error'),
          );
        },
        build: () => newInstance(),
        act: (cubit) async {
          Future.delayed(const Duration(milliseconds: 100));
          cubit.addToFavorites(word);
        },
        expect: () => [
          isA<TranslationFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test add to favorites error'),
          ),
          isA<TranslationLoadedState>().having(
            (state) => state.translation.word.word,
            'word',
            equals('word 1'),
          ),
          isA<TranslationInFavoritesState>().having(
            (state) => state.inFavorites,
            'inFavorites',
            isFalse,
          ),
        ],
        verify: (_) {
          verify(() => favoritesRepository.add(word)).called(1);
        },
      );

      blocTest(
        'emits ok state when saving to favorites',
        setUp: () {
          word = MockWord();
          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: Uri.parse('https://skarnik.by/word/test'),
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => translation,
          );

          when(
            () => favoritesRepository.contains(word),
          ).thenAnswer(
            (_) async => false,
          );

          when(
            () => historyRepository.save(word),
          ).thenAnswer(
            (_) async => 1,
          );

          when(
            () => analyticsTranslationRepository.logTranslation(translation),
          ).thenAnswer(
            (_) async => true,
          );

          when(
            () => favoritesRepository.add(word),
          ).thenAnswer(
            (_) async => 1,
          );
        },
        build: () => newInstance(),
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
          cubit.addToFavorites(word);
        },
        expect: () => [
          isA<TranslationLoadedState>().having(
            (state) => state.translation.word.word,
            'word',
            equals('word 1'),
          ),
          isA<TranslationInFavoritesState>().having(
            (state) => state.inFavorites,
            'inFavorites',
            isFalse,
          ),
          isA<TranslationAddedToFavoritesState>(),
          isA<TranslationInFavoritesState>().having(
            (state) => state.inFavorites,
            'inFavorites',
            isTrue,
          ),
        ],
        verify: (_) {
          verify(() => favoritesRepository.add(word)).called(1);
        },
      );
    });

    group('removeFromFavorites()', () {
      late Word word;

      blocTest(
        'emits failed state when removing from favorites',
        setUp: () {
          word = MockWord();
          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: Uri.parse('https://skarnik.by/word/test'),
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => translation,
          );

          when(
            () => favoritesRepository.contains(word),
          ).thenAnswer(
            (_) async => false,
          );

          when(
            () => historyRepository.save(word),
          ).thenAnswer(
            (_) async => 1,
          );

          when(
            () => analyticsTranslationRepository.logTranslation(translation),
          ).thenAnswer(
            (_) async => true,
          );

          when(
            () => favoritesRepository.remove(word),
          ).thenThrow(
            UnimplementedError('test remove from favorites error'),
          );
        },
        build: () => newInstance(),
        act: (cubit) async {
          Future.delayed(const Duration(milliseconds: 100));
          cubit.removeFromFavorites(word);
        },
        expect: () => [
          isA<TranslationFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test remove from favorites error'),
          ),
          isA<TranslationLoadedState>().having(
            (state) => state.translation.word.word,
            'word',
            equals('word 1'),
          ),
          isA<TranslationInFavoritesState>().having(
            (state) => state.inFavorites,
            'inFavorites',
            isFalse,
          ),
        ],
        verify: (_) {
          verify(() => favoritesRepository.remove(word)).called(1);
        },
      );

      blocTest(
        'emits ok state when removing from favorites',
        setUp: () {
          word = MockWord();
          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: Uri.parse('https://skarnik.by/word/test'),
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => translationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => translation,
          );

          when(
            () => favoritesRepository.contains(word),
          ).thenAnswer(
            (_) async => false,
          );

          when(
            () => historyRepository.save(word),
          ).thenAnswer(
            (_) async => 1,
          );

          when(
            () => analyticsTranslationRepository.logTranslation(translation),
          ).thenAnswer(
            (_) async => true,
          );

          when(
            () => favoritesRepository.remove(word),
          ).thenAnswer(
            (_) async => true,
          );
        },
        build: () => newInstance(),
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
          cubit.removeFromFavorites(word);
        },
        expect: () => [
          isA<TranslationLoadedState>().having(
            (state) => state.translation.word.word,
            'word',
            equals('word 1'),
          ),
          isA<TranslationInFavoritesState>().having(
            (state) => state.inFavorites,
            'inFavorites',
            isFalse,
          ),
          isA<TranslationRemovedFromFavoritesState>(),
          isA<TranslationInFavoritesState>().having(
            (state) => state.inFavorites,
            'inFavorites',
            isFalse,
          ),
        ],
        verify: (_) {
          verify(() => favoritesRepository.remove(word)).called(1);
        },
      );
    });
  });
}
