import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/analytics_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_translation.dart';

class MockAnalyticsTranslationRepository extends Mock implements AnalyticsTranslationRepository {}

class MockWord extends Mock implements Word {}

void main() {
  late LogAnalyticsTranslationUseCase useCase;
  late MockAnalyticsTranslationRepository mockRepository;
  late Translation testTranslation;
  late MockWord mockWord;

  setUp(() {
    mockRepository = MockAnalyticsTranslationRepository();
    useCase = LogAnalyticsTranslationUseCase(mockRepository);

    mockWord = MockWord();
    when(() => mockWord.word).thenReturn('тэст');
    when(() => mockWord.wordId).thenReturn(123);
    when(() => mockWord.dictionary).thenReturn(Dictionary.belRus);
    when(
      () => mockWord.buildApiUri(),
    ).thenReturn(Uri.parse('https://api.skarnik.by/api/words/belrus/123/'));

    testTranslation = Translation.build(
      uri: mockWord.buildApiUri(),
      word: mockWord,
      html: '<div>Test translation</div>',
      source: 'api',
    );
  });

  group('LogAnalyticsTranslationUseCase', () {
    test('should return Success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.logTranslation(testTranslation)).thenAnswer((_) async => {});

      // Act
      final result = await useCase.call(testTranslation);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logTranslation(testTranslation)).called(1);
    });

    test('should return Success even when repository throws an exception', () async {
      // Arrange
      when(
        () => mockRepository.logTranslation(testTranslation),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call(testTranslation);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logTranslation(testTranslation)).called(1);
    });

    test('should log warning when repository throws an exception', () async {
      // Arrange - we can't directly verify logger calls in this test,
      // but we can verify the exception is caught and Success is returned
      when(
        () => mockRepository.logTranslation(testTranslation),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call(testTranslation);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
    });

    test('should return Success with different translation objects', () async {
      // Arrange
      final anotherMockWord = MockWord();
      when(() => anotherMockWord.word).thenReturn('іншы');
      when(() => anotherMockWord.wordId).thenReturn(456);
      when(() => anotherMockWord.dictionary).thenReturn(Dictionary.rusBel);
      when(
        () => anotherMockWord.buildApiUri(),
      ).thenReturn(Uri.parse('https://api.skarnik.by/api/words/rusbel/456/'));

      final anotherTranslation = Translation.build(
        uri: anotherMockWord.buildApiUri(),
        word: anotherMockWord,
        html: '<div>Another translation</div>',
        source: 'cloud',
      );

      when(() => mockRepository.logTranslation(anotherTranslation)).thenAnswer((_) async => {});

      // Act
      final result = await useCase.call(anotherTranslation);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logTranslation(anotherTranslation)).called(1);
    });
  });
}
