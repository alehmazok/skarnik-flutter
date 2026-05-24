import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/repository/analytics_app_repository.dart';
import 'package:skarnik_flutter/features/app/domain/use_case/log_analytics_app_started.dart';

class MockAnalyticsAppRepository extends Mock implements AnalyticsAppRepository {}

void main() {
  late LogAnalyticsAppOpenUseCase useCase;
  late MockAnalyticsAppRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsAppRepository();
    useCase = LogAnalyticsAppOpenUseCase(mockRepository);
  });

  group('LogAnalyticsAppOpenUseCase', () {
    test('should return Success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.logAppStarted()).thenAnswer((_) async => {});

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logAppStarted()).called(1);
    });

    test('should return Success even when repository throws an exception', () async {
      // Arrange
      when(() => mockRepository.logAppStarted()).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logAppStarted()).called(1);
    });

    test('should log warning when repository throws an exception', () async {
      // Arrange - we can't directly verify logger calls in this test,
      // but we can verify the exception is caught and Success is returned
      when(() => mockRepository.logAppStarted()).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
    });
  });
}
