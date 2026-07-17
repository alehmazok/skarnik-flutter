import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_row.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_source.dart';
import 'package:skarnik_flutter/features/stress/domain/repository/cloud_stress_repository.dart';
import 'package:skarnik_flutter/features/stress/domain/repository/stress_repository.dart';
import 'package:skarnik_flutter/features/stress/domain/use_case/get_stress_table.dart';

class MockStressRepository extends Mock implements StressRepository {}

class MockCloudStressRepository extends Mock implements CloudStressRepository {}

const _rows = [StressRow(title: 'Назоўны', content: 'сло́ва')];

void main() {
  late GetStressTableUseCase useCase;
  late MockStressRepository apiRepository;
  late MockCloudStressRepository cloudRepository;

  setUp(() {
    apiRepository = MockStressRepository();
    cloudRepository = MockCloudStressRepository();
    useCase = GetStressTableUseCase(apiRepository, cloudRepository);
  });

  group('GetStressTableUseCase', () {
    test('routes to the API repository for StressSource.api', () async {
      when(() => apiRepository.getStressTable(1)).thenAnswer((_) async => _rows);

      final result = await useCase.call(1, StressSource.api);

      expect(result, isA<Success<List<StressRow>>>());
      expect((result as Success).result, _rows);
      verify(() => apiRepository.getStressTable(1)).called(1);
      verifyNever(() => cloudRepository.getStressTable(any()));
    });

    test('routes to the cloud repository for StressSource.cloud', () async {
      when(() => cloudRepository.getStressTable(11)).thenAnswer((_) async => _rows);

      final result = await useCase.call(11, StressSource.cloud);

      expect(result, isA<Success<List<StressRow>>>());
      expect((result as Success).result, _rows);
      verify(() => cloudRepository.getStressTable(11)).called(1);
      verifyNever(() => apiRepository.getStressTable(any()));
    });

    test('does not retry the other source when the routed one fails', () async {
      final error = Exception('api down');
      when(() => apiRepository.getStressTable(1)).thenThrow(error);

      final result = await useCase.call(1, StressSource.api);

      expect(result, isA<Failure<List<StressRow>>>());
      expect((result as Failure).error, error);
      verifyNever(() => cloudRepository.getStressTable(any()));
    });

    test('returns Failure(null) when rows are empty', () async {
      when(() => apiRepository.getStressTable(1)).thenAnswer((_) async => []);

      final result = await useCase.call(1, StressSource.api);

      expect(result, isA<Failure<List<StressRow>>>());
      expect((result as Failure).error, isNull);
    });
  });
}
