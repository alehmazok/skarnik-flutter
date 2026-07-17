import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_source.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_word_entry.dart';
import 'package:skarnik_flutter/features/stress/domain/repository/cloud_stress_repository.dart';
import 'package:skarnik_flutter/features/stress/domain/repository/stress_repository.dart';
import 'package:skarnik_flutter/features/stress/domain/use_case/resolve_stress_word_list.dart';

class MockStressRepository extends Mock implements StressRepository {}

class MockCloudStressRepository extends Mock implements CloudStressRepository {}

const _word = 'слова';

const _apiEntry = StressWordEntry(id: 1, lemma: _word, word: 'сло́ва', source: StressSource.api);
const _cloudEntry = StressWordEntry(
  id: 11,
  lemma: _word,
  word: 'сло́ва',
  source: StressSource.cloud,
);
const _unrelatedEntry = StressWordEntry(
  id: 2,
  lemma: 'іншае',
  word: 'іншае',
  source: StressSource.api,
);

void main() {
  late ResolveStressWordListUseCase useCase;
  late MockStressRepository apiRepository;
  late MockCloudStressRepository cloudRepository;

  setUp(() {
    apiRepository = MockStressRepository();
    cloudRepository = MockCloudStressRepository();
    useCase = ResolveStressWordListUseCase(apiRepository, cloudRepository);
  });

  group('ResolveStressWordListUseCase', () {
    test('returns Success from the API repository when it has an exact match', () async {
      when(() => apiRepository.resolveWordList(_word)).thenAnswer((_) async => [_apiEntry]);

      final result = await useCase.call(_word);

      expect(result, isA<Success<List<StressWordEntry>>>());
      expect((result as Success).result, [_apiEntry]);
      verify(() => apiRepository.resolveWordList(_word)).called(1);
      verifyNever(() => cloudRepository.resolveWordList(any()));
    });

    test('falls back to cloud when API throws', () async {
      when(() => apiRepository.resolveWordList(_word)).thenThrow(Exception('API down'));
      when(() => cloudRepository.resolveWordList(_word)).thenAnswer((_) async => [_cloudEntry]);

      final result = await useCase.call(_word);

      expect(result, isA<Success<List<StressWordEntry>>>());
      expect((result as Success).result, [_cloudEntry]);
      verify(() => apiRepository.resolveWordList(_word)).called(1);
      verify(() => cloudRepository.resolveWordList(_word)).called(1);
    });

    test('falls back to cloud when API has no exact match', () async {
      when(() => apiRepository.resolveWordList(_word)).thenAnswer((_) async => [_unrelatedEntry]);
      when(() => cloudRepository.resolveWordList(_word)).thenAnswer((_) async => [_cloudEntry]);

      final result = await useCase.call(_word);

      expect(result, isA<Success<List<StressWordEntry>>>());
      expect((result as Success).result, [_cloudEntry]);
    });

    test('returns Failure(null) when neither source has an exact match', () async {
      when(() => apiRepository.resolveWordList(_word)).thenAnswer((_) async => []);
      when(() => cloudRepository.resolveWordList(_word)).thenAnswer((_) async => []);

      final result = await useCase.call(_word);

      expect(result, isA<Failure<List<StressWordEntry>>>());
      expect((result as Failure).error, isNull);
    });

    test('returns Failure when both sources throw', () async {
      final cloudError = Exception('cloud down');
      when(() => apiRepository.resolveWordList(_word)).thenThrow(Exception('api down'));
      when(() => cloudRepository.resolveWordList(_word)).thenThrow(cloudError);

      final result = await useCase.call(_word);

      expect(result, isA<Failure<List<StressWordEntry>>>());
      expect((result as Failure).error, cloudError);
    });
  });
}
