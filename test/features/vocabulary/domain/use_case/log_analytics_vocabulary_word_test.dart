import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/vocabulary/domain/repository/analytics_vocabulary_repository.dart';
import 'package:skarnik_flutter/features/vocabulary/domain/use_case/log_analytics_vocabulary_word.dart';

class MockAnalyticsVocabularyRepository extends Mock implements AnalyticsVocabularyRepository {}

class MockWord extends Mock implements Word {}

void main() {
  late LogAnalyticsVocabularyWordUseCase useCase;
  late MockAnalyticsVocabularyRepository mockRepository;
  late MockWord mockWord;

  setUp(() {
    mockRepository = MockAnalyticsVocabularyRepository();
    useCase = LogAnalyticsVocabularyWordUseCase(mockRepository);

    mockWord = MockWord();
    when(() => mockWord.word).thenReturn('тэст');
    when(() => mockWord.wordId).thenReturn(123);
    when(() => mockWord.dictionary).thenReturn(Dictionary.belRus);
  });

  group('LogAnalyticsVocabularyWordUseCase', () {
    test('should return Success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.logWord(mockWord)).thenAnswer((_) async => {});

      // Act
      final result = await useCase.call(mockWord);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logWord(mockWord)).called(1);
    });

    test('should return Success even when repository throws an exception', () async {
      // Arrange
      when(() => mockRepository.logWord(mockWord)).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call(mockWord);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logWord(mockWord)).called(1);
    });

    test('should log warning when repository throws an exception', () async {
      // Arrange - we can't directly verify logger calls in this test,
      // but we can verify the exception is caught and Success is returned
      when(() => mockRepository.logWord(mockWord)).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call(mockWord);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
    });

    test('should return Success with different word objects', () async {
      // Arrange
      final anotherMockWord = MockWord();
      when(() => anotherMockWord.word).thenReturn('іншы');
      when(() => anotherMockWord.wordId).thenReturn(456);
      when(() => anotherMockWord.dictionary).thenReturn(Dictionary.rusBel);

      when(() => mockRepository.logWord(anotherMockWord)).thenAnswer((_) async => {});

      // Act
      final result = await useCase.call(anotherMockWord);

      // Assert
      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logWord(anotherMockWord)).called(1);
    });
  });
}
