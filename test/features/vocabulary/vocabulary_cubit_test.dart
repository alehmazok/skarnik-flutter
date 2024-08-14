import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/vocabulary/domain/repository/analytics_vocabulary_repository.dart';
import 'package:skarnik_flutter/features/vocabulary/domain/repository/vocabulary_repository.dart';
import 'package:skarnik_flutter/features/vocabulary/domain/use_case/load_vocabulary.dart';
import 'package:skarnik_flutter/features/vocabulary/domain/use_case/log_analytics_vocabulary_word.dart';
import 'package:skarnik_flutter/features/vocabulary/presentation/vocabulary_cubit.dart';

class MockVocabularyRepository extends Mock implements VocabularyRepository {}

class MockAnalyticsVocabularyRepository extends Mock implements AnalyticsVocabularyRepository {}

class MockTickerProvider extends Mock implements TickerProvider {}

class MockTicker extends Mock implements Ticker {
  @override
  String toString({bool debugIncludeStack = false}) => 'Mock Ticker';
}

class MockWord extends Mock implements Word {}

void main() {
  final analyticsVocabularyRepository = MockAnalyticsVocabularyRepository();

  group('VocabularyCubit', () {
    final tickerProvider = MockTickerProvider();
    setUp(() {
      when(
        () => tickerProvider.createTicker(any()),
      ).thenReturn(
        MockTicker(),
      );
    });

    VocabularyCubit newInstance(
      VocabularyRepository vocabularyRepository,
      AnalyticsVocabularyRepository analyticsRepository,
    ) =>
        VocabularyCubit(
          loadVocabularyUseCase: LoadVocabularyUseCase(vocabularyRepository),
          logAnalyticsVocabularyWordUseCase: LogAnalyticsVocabularyWordUseCase(analyticsRepository),
          tickerProvider: tickerProvider,
        );

    group('loadWords()', () {
      final vocabularyRepository = MockVocabularyRepository();
      late final Word word1;
      late final Word word2;

      blocTest(
        'emits failed state when failed to get words from database',
        setUp: () {
          when(
            () => vocabularyRepository.getWords(any()),
          ).thenThrow(
            UnimplementedError('test get words error'),
          );
        },
        build: () => newInstance(
          vocabularyRepository,
          analyticsVocabularyRepository,
        ),
        act: (cubit) => cubit.loadWords(1),
        expect: () => [
          isA<VocabularyInitedState>(),
          isA<VocabularyFailedState>().having(
            (state) => (state.error as UnimplementedError).message,
            'message',
            equals('test get words error'),
          ),
        ],
      );

      blocTest(
        'emits ok state when successfully got words from database',
        setUp: () {
          word1 = MockWord();
          word2 = MockWord();

          when(
            () => vocabularyRepository.getWords(any()),
          ).thenAnswer(
            (_) async => [word1, word2],
          );
        },
        build: () => newInstance(
          vocabularyRepository,
          analyticsVocabularyRepository,
        ),
        act: (cubit) => cubit.loadWords(1),
        expect: () => [
          isA<VocabularyInitedState>(),
          isA<VocabularyLoadedState>().having(
            (state) => state.words,
            'words',
            equals([word1, word2]),
          ),
        ],
      );
    });

    group('loadWords() from cache', () {
      final vocabularyRepository = MockVocabularyRepository();
      late final Word word1;
      late final Word word2;

      blocTest(
        'emits ok state when successfully got words from cache',
        setUp: () {
          word1 = MockWord();
          word2 = MockWord();

          when(
            () => vocabularyRepository.getWords(any()),
          ).thenAnswer(
            (_) async => [word1, word2],
          );
        },
        build: () => newInstance(
          vocabularyRepository,
          analyticsVocabularyRepository,
        ),
        act: (cubit) async {
          cubit.loadWords(1);
          await Future.delayed(const Duration(milliseconds: 100));
          cubit.loadWords(1);
        },
        expect: () => [
          isA<VocabularyInitedState>(),
          isA<VocabularyLoadedState>().having(
            (state) => state.words,
            'words',
            equals([word1, word2]),
          ),
          isA<VocabularyInitedState>(),
          isA<VocabularyLoadedState>().having(
            (state) => state.words,
            'words',
            equals([word1, word2]),
          ),
        ],
        verify: (_) {
          verify(() => vocabularyRepository.getWords(1)).called(1);
        },
      );
    });
  });
}
