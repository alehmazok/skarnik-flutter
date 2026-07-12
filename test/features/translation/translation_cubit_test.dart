import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/review/domain/use_case/check_and_request_review.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/analytics_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/api_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/cloud_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/favorites_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/local_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/website_translation_repository.dart';
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

class MockCloudTranslationRepository extends Mock implements CloudTranslationRepository {}

class MockLocalTranslationRepository extends Mock implements LocalTranslationRepository {}

class MockWebsiteTranslationRepository extends Mock implements WebsiteTranslationRepository {}

class MockApiWordRepository extends Mock implements ApiTranslationRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockAnalyticsTranslationRepository extends Mock implements AnalyticsTranslationRepository {}

class MockCheckAndRequestReviewUseCase extends Mock implements CheckAndRequestReviewUseCase {}

class MockWord extends Mock implements Word {}

void main() {
  group('TranslationCubit', () {
    final wordRepository = MockWordRepository();
    final apiTranslationRepository = MockApiWordRepository();
    final cloudTranslationRepository = MockCloudTranslationRepository();
    final localTranslationRepository = MockLocalTranslationRepository();
    final websiteTranslationRepository = MockWebsiteTranslationRepository();
    final favoritesRepository = MockFavoritesRepository();
    final historyRepository = MockHistoryRepository();
    final analyticsTranslationRepository = MockAnalyticsTranslationRepository();
    final checkAndRequestReviewUseCase = MockCheckAndRequestReviewUseCase();

    setUp(() {
      reset(checkAndRequestReviewUseCase);
      when(() => checkAndRequestReviewUseCase.call()).thenAnswer((_) async => const Success(false));
      when(
        () => localTranslationRepository.getWord(
          langId: any(named: 'langId'),
          wordId: any(named: 'wordId'),
        ),
      ).thenAnswer((_) async => null);
    });

    TranslationCubit newInstance({bool saveToHistory = true}) => TranslationCubit(
      langId: 1,
      wordId: 1,
      saveToHistory: saveToHistory,
      getWordUseCase: GetWordUseCase(wordRepository),
      getTranslationUseCase: GetTranslationUseCase(
        localTranslationRepository: localTranslationRepository,
        apiWordRepository: apiTranslationRepository,
        cloudTranslationRepository: cloudTranslationRepository,
        websiteTranslationRepository: websiteTranslationRepository,
      ),
      addToFavoritesUseCase: AddToFavoritesUseCase(favoritesRepository),
      checkInFavoritesUseCase: CheckInFavoritesUseCase(favoritesRepository),
      removeFromFavoritesUseCase: RemoveFromFavoritesUseCase(favoritesRepository),
      saveToHistoryUseCase: SaveToHistoryUseCase(historyRepository),
      logAnalyticsTranslationUseCase: LogAnalyticsTranslationUseCase(
        analyticsTranslationRepository,
      ),
      logAnalyticsAddToFavoritesUseCase: LogAnalyticsAddToFavoritesUseCase(
        analyticsTranslationRepository,
      ),
      logAnalyticsShareUseCase: LogAnalyticsShareUseCase(analyticsTranslationRepository),
      checkAndRequestReviewUseCase: checkAndRequestReviewUseCase,
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
        'emits error state when failed to get translation from both primary and fallback data sources',
        setUp: () {
          final word = MockWord();
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => apiTranslationRepository.getTranslation(word),
          ).thenThrow(
            UnimplementedError('test primary translation error'),
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
          ).thenThrow(
            UnimplementedError('test fallback translation error'),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<TranslationFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test fallback translation error'),
          ),
        ],
      );

      blocTest(
        'emits failed state when failed to check the word is in favorites',
        setUp: () {
          final word = MockWord();
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);
          final uri = Uri.parse('https://skarnik.by/word/test');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => Translation.build(
              word: word,
              html: '<div>test</div>',
              uri: uri,
              source: 'website',
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
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);
          final uri = Uri.parse('https://skarnik.by/word/test');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
          ).thenAnswer(
            (_) async => Translation.build(
              word: word,
              html: '<div>test</div>',
              uri: uri,
              source: 'website',
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
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);
          final uri = Uri.parse('https://skarnik.by/word/test');

          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: uri,
            source: 'website',
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
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
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);
          final uri = Uri.parse('https://skarnik.by/word/test');

          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: uri,
            source: 'website',
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
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

      blocTest(
        'triggers review check after a successful word view',
        setUp: () {
          final word = MockWord();
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);
          final uri = Uri.parse('https://skarnik.by/word/test');

          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: uri,
            source: 'website',
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
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
        build: () => newInstance(),
        expect: () => [
          isA<TranslationLoadedState>(),
          isA<TranslationInFavoritesState>(),
        ],
        verify: (_) {
          verify(() => checkAndRequestReviewUseCase.call()).called(1);
        },
      );
    });

    group('addToFavorites()', () {
      late Word word;

      blocTest(
        'emits failed state when saving to favorites',
        setUp: () {
          word = MockWord();
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);
          final uri = Uri.parse('https://skarnik.by/word/test');

          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: uri,
            source: 'website',
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
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
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);
          final uri = Uri.parse('https://skarnik.by/word/test');

          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: uri,
            source: 'website',
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
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

    group('share()', () {
      late Word word;
      late Translation translation;

      setUp(() {
        word = MockWord();
        when(() => word.langId).thenReturn(1);
        when(() => word.wordId).thenReturn(1);
        final uri = Uri.parse('https://skarnik.by/word/test');

        translation = Translation.build(
          word: word,
          html: '<div>test</div>',
          uri: uri,
          source: 'website',
        );

        when(() => word.word).thenReturn('слова');
        when(() => word.dictionary).thenReturn(Dictionary.belRus);
        when(() => word.wordId).thenReturn(42);

        when(
          () => wordRepository.getWord(langId: 1, wordId: 1),
        ).thenAnswer((_) async => word);

        when(
          () => websiteTranslationRepository.getTranslation(word),
        ).thenAnswer((_) async => translation);

        when(
          () => favoritesRepository.contains(word),
        ).thenAnswer((_) async => false);

        when(
          () => historyRepository.save(word),
        ).thenAnswer((_) async => 1);

        when(
          () => analyticsTranslationRepository.logShare(any()),
        ).thenAnswer((_) async {});

        TestWidgetsFlutterBinding.ensureInitialized();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/share'),
          (MethodCall methodCall) async => null,
        );
      });

      blocTest(
        'calls logShare with share uri',
        build: () => newInstance(),
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
          await cubit.share(translation);
        },
        expect: () => [
          isA<TranslationLoadedState>(),
          isA<TranslationInFavoritesState>(),
        ],
        verify: (_) {
          verify(
            () => analyticsTranslationRepository.logShare(
              'https://skarnik.app/r/belrus/42',
            ),
          ).called(1);
        },
      );

      blocTest(
        'does not emit state during share',
        build: () => newInstance(),
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 100));
          await cubit.share(translation);
        },
        expect: () => [
          isA<TranslationLoadedState>(),
          isA<TranslationInFavoritesState>(),
        ],
      );
    });

    group('removeFromFavorites()', () {
      late Word word;
      late Uri uri;

      blocTest(
        'emits failed state when removing from favorites',
        setUp: () {
          word = MockWord();
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);

          uri = Uri.parse('https://skarnik.by/word/test');

          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: uri,
            source: 'website',
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
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
          when(() => word.langId).thenReturn(1);
          when(() => word.wordId).thenReturn(1);

          final translation = Translation.build(
            word: word,
            html: '<div>test</div>',
            uri: uri,
            source: 'website',
          );

          when(() => word.word).thenReturn('word 1');

          when(
            () => wordRepository.getWord(langId: 1, wordId: 1),
          ).thenAnswer(
            (_) async => word,
          );

          when(
            () => websiteTranslationRepository.getTranslation(word),
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
