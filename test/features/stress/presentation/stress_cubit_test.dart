import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_row.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_source.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_word_entry.dart';
import 'package:skarnik_flutter/features/stress/domain/repository/analytics_stress_repository.dart';
import 'package:skarnik_flutter/features/stress/domain/repository/cloud_stress_repository.dart';
import 'package:skarnik_flutter/features/stress/domain/repository/stress_repository.dart';
import 'package:skarnik_flutter/features/stress/domain/use_case/get_stress_table.dart';
import 'package:skarnik_flutter/features/stress/domain/use_case/log_analytics_stress.dart';
import 'package:skarnik_flutter/features/stress/domain/use_case/resolve_stress_word_list.dart';
import 'package:skarnik_flutter/features/stress/presentation/stress_cubit.dart';

class MockStressRepository extends Mock implements StressRepository {}

class MockCloudStressRepository extends Mock implements CloudStressRepository {}

class MockAnalyticsStressRepository extends Mock implements AnalyticsStressRepository {}

const _word = 'слова';

const _entry1 = StressWordEntry(id: 1, lemma: _word, word: 'сло́ва', source: StressSource.api);
const _entry2 = StressWordEntry(
  id: 2,
  lemma: _word,
  word: 'сло́вы',
  tableName: 'Табліца 2',
  source: StressSource.api,
);
const _entry3 = StressWordEntry(id: 3, lemma: 'іншае', word: 'іншае', source: StressSource.api);
const _cloudEntry1 = StressWordEntry(
  id: 11,
  lemma: _word,
  word: 'сло́ва',
  source: StressSource.cloud,
);

const _rows = [
  StressRow(title: 'Назоўны', content: 'сло́ва'),
  StressRow(title: 'Родны', content: 'сло́вы'),
];

void main() {
  group('StressCubit', () {
    late MockStressRepository stressRepository;
    late MockCloudStressRepository cloudStressRepository;
    late MockAnalyticsStressRepository analyticsRepository;

    setUp(() {
      stressRepository = MockStressRepository();
      cloudStressRepository = MockCloudStressRepository();
      analyticsRepository = MockAnalyticsStressRepository();
      when(() => analyticsRepository.logStressClicked(any())).thenAnswer((_) async {});
    });

    StressCubit newInstance({String word = _word}) => StressCubit(
      word: word,
      logAnalyticsStressUseCase: LogAnalyticsStressUseCase(analyticsRepository),
      resolveStressWordListUseCase: ResolveStressWordListUseCase(
        stressRepository,
        cloudStressRepository,
      ),
    );

    blocTest(
      'emits StressWordSelectedState(replace: true) when exactly one exact match',
      setUp: () {
        when(
          () => stressRepository.resolveWordList(_word),
        ).thenAnswer((_) async => [_entry1]);
      },
      build: newInstance,
      expect: () => [
        isA<StressWordSelectedState>()
            .having((s) => s.wordId, 'wordId', equals(1))
            .having((s) => s.source, 'source', equals(StressSource.api))
            .having((s) => s.replace, 'replace', isTrue),
      ],
    );

    blocTest(
      'emits StressWordSelectionState when multiple exact matches',
      setUp: () {
        when(
          () => stressRepository.resolveWordList(_word),
        ).thenAnswer((_) async => [_entry1, _entry2]);
      },
      build: newInstance,
      expect: () => [
        isA<StressWordSelectionState>().having(
          (s) => s.words,
          'words',
          equals([_entry1, _entry2]),
        ),
      ],
    );

    blocTest(
      'emits StressNotFoundState when no exact match on either source',
      setUp: () {
        when(
          () => stressRepository.resolveWordList(_word),
        ).thenAnswer((_) async => [_entry3]);
        when(
          () => cloudStressRepository.resolveWordList(_word),
        ).thenAnswer((_) async => []);
      },
      build: newInstance,
      expect: () => [isA<StressNotFoundState>()],
    );

    blocTest(
      'emits StressNotFoundState when list is empty on either source',
      setUp: () {
        when(
          () => stressRepository.resolveWordList(_word),
        ).thenAnswer((_) async => []);
        when(
          () => cloudStressRepository.resolveWordList(_word),
        ).thenAnswer((_) async => []);
      },
      build: newInstance,
      expect: () => [isA<StressNotFoundState>()],
    );

    blocTest(
      'falls back to cloud when api throws',
      setUp: () {
        when(
          () => stressRepository.resolveWordList(_word),
        ).thenThrow(UnimplementedError('api down'));
        when(
          () => cloudStressRepository.resolveWordList(_word),
        ).thenAnswer((_) async => [_cloudEntry1]);
      },
      build: newInstance,
      expect: () => [
        isA<StressWordSelectedState>()
            .having((s) => s.wordId, 'wordId', equals(11))
            .having((s) => s.source, 'source', equals(StressSource.cloud))
            .having((s) => s.replace, 'replace', isTrue),
      ],
    );

    blocTest(
      'emits StressFailedState when both api and cloud throw',
      setUp: () {
        when(
          () => stressRepository.resolveWordList(_word),
        ).thenThrow(UnimplementedError('api down'));
        when(
          () => cloudStressRepository.resolveWordList(_word),
        ).thenThrow(UnimplementedError('cloud down'));
      },
      build: newInstance,
      expect: () => [
        isA<StressFailedState>().having(
          (s) => (s.error as UnimplementedError).message,
          'message',
          equals('cloud down'),
        ),
      ],
    );

    blocTest(
      'analytics fires and failure is swallowed',
      setUp: () {
        when(
          () => analyticsRepository.logStressClicked(_word),
        ).thenThrow(UnimplementedError('analytics error'));
        when(
          () => stressRepository.resolveWordList(_word),
        ).thenAnswer((_) async => [_entry1]);
      },
      build: newInstance,
      expect: () => [
        isA<StressWordSelectedState>(),
      ],
    );

    group('selectWord()', () {
      blocTest(
        'emits StressWordSelectedState(replace: false) then reverts to prior state',
        setUp: () {
          when(
            () => stressRepository.resolveWordList(_word),
          ).thenAnswer((_) async => [_entry1, _entry2]);
        },
        build: newInstance,
        act: (cubit) async {
          await Future.delayed(const Duration(milliseconds: 50));
          cubit.selectWord(_entry2);
        },
        expect: () => [
          isA<StressWordSelectionState>(),
          isA<StressWordSelectedState>()
              .having((s) => s.wordId, 'wordId', equals(2))
              .having((s) => s.source, 'source', equals(StressSource.api))
              .having((s) => s.replace, 'replace', isFalse),
          isA<StressWordSelectionState>().having(
            (s) => s.words,
            'words',
            equals([_entry1, _entry2]),
          ),
        ],
      );
    });
  });

  group('StressTableCubit', () {
    late MockStressRepository stressRepository;
    late MockCloudStressRepository cloudStressRepository;

    setUp(() {
      stressRepository = MockStressRepository();
      cloudStressRepository = MockCloudStressRepository();
    });

    StressTableCubit newInstance() => StressTableCubit(
      getStressTableUseCase: GetStressTableUseCase(stressRepository, cloudStressRepository),
    );

    blocTest(
      'emits StressLoadedState on success',
      setUp: () {
        when(
          () => stressRepository.getStressTable(1),
        ).thenAnswer((_) async => _rows);
      },
      build: newInstance,
      act: (cubit) => cubit.load(1, StressSource.api),
      expect: () => [
        isA<StressLoadedState>().having((s) => s.rows, 'rows', equals(_rows)),
      ],
    );

    blocTest(
      'emits StressLoadedState from cloud source without touching api',
      setUp: () {
        when(
          () => cloudStressRepository.getStressTable(11),
        ).thenAnswer((_) async => _rows);
      },
      build: newInstance,
      act: (cubit) => cubit.load(11, StressSource.cloud),
      expect: () => [
        isA<StressLoadedState>().having((s) => s.rows, 'rows', equals(_rows)),
      ],
      verify: (_) {
        verifyNever(() => stressRepository.getStressTable(any()));
      },
    );

    blocTest(
      'emits StressNotFoundState when table is empty',
      setUp: () {
        when(
          () => stressRepository.getStressTable(1),
        ).thenAnswer((_) async => []);
      },
      build: newInstance,
      act: (cubit) => cubit.load(1, StressSource.api),
      expect: () => [isA<StressNotFoundState>()],
    );

    blocTest(
      'emits StressFailedState when getStressTable throws',
      setUp: () {
        when(
          () => stressRepository.getStressTable(1),
        ).thenThrow(UnimplementedError('table error'));
      },
      build: newInstance,
      act: (cubit) => cubit.load(1, StressSource.api),
      expect: () => [
        isA<StressFailedState>().having(
          (s) => (s.error as UnimplementedError).message,
          'message',
          equals('table error'),
        ),
      ],
    );
  });
}
