import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/analytics_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_share.dart';

class MockAnalyticsTranslationRepository extends Mock implements AnalyticsTranslationRepository {}

void main() {
  late LogAnalyticsShareUseCase useCase;
  late MockAnalyticsTranslationRepository mockRepository;
  late String testLink;

  setUp(() {
    mockRepository = MockAnalyticsTranslationRepository();
    useCase = LogAnalyticsShareUseCase(mockRepository);
    testLink = 'https://skarnik.by/belrus/123';
  });

  group('LogAnalyticsShareUseCase', () {
    test('should return Success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.logShare(testLink)).thenAnswer((_) async => {});

      // Act
      final result = await useCase.call(testLink);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logShare(testLink)).called(1);
    });

    test('should return Success even when repository throws an exception', () async {
      // Arrange
      when(() => mockRepository.logShare(testLink)).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call(testLink);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logShare(testLink)).called(1);
    });

    test('should log warning when repository throws an exception', () async {
      // Arrange - we can't directly verify logger calls in this test,
      // but we can verify the exception is caught and Success is returned
      when(() => mockRepository.logShare(testLink)).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call(testLink);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
    });

    test('should return Success with different link values', () async {
      // Arrange
      const anotherLink = 'https://skarnik.by/rusbel/456';

      when(() => mockRepository.logShare(anotherLink)).thenAnswer((_) async => {});

      // Act
      final result = await useCase.call(anotherLink);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logShare(anotherLink)).called(1);
    });
  });
}
