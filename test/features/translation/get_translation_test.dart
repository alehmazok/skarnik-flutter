import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/data/model/api_word_model.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/api_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart';

class MockApiWordRepository extends Mock implements ApiTranslationRepository {}

class MockFallbackTranslationRepository extends Mock implements FallbackTranslationRepository {}

class MockWord extends Mock implements Word {}

void main() {
  late GetTranslationUseCase useCase;
  late MockApiWordRepository mockApiWordRepository;
  late MockFallbackTranslationRepository mockFallbackTranslationRepository;

  setUp(() {
    mockApiWordRepository = MockApiWordRepository();
    mockFallbackTranslationRepository = MockFallbackTranslationRepository();
    useCase = GetTranslationUseCase(
      apiWordRepository: mockApiWordRepository,
      fallbackTranslationRepository: mockFallbackTranslationRepository,
    );
  });

  group('GetTranslationUseCase', () {
    final word = MockWord();
    late Translation translation;

    final apiWord = ApiWordModel(
      (b) => b
        ..externalId = 1
        ..translation = '<div></div>'
        ..redirectTo = null,
    );

    setUpAll(() {
      when(
        () => word.buildApiUri(),
      ).thenReturn(
        Uri.parse('https://skarnik.by/belrus/1'),
      );

      translation = Translation.build(
        uri: word.buildApiUri(),
        html: '<div></div>',
        word: word,
      );
    });

    test('should return ApiWord from the API repository when successful', () async {
      // Arrange
      when(
        () => mockApiWordRepository.getTranslation(word),
      ).thenAnswer(
        (_) async => apiWord.toEntity(),
      );

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Success<Translation>>());
      expect((result as Success).result, translation);
      verify(() => mockApiWordRepository.getTranslation(word)).called(1);
      verifyNever(() => mockFallbackTranslationRepository.getTranslation(word));
    });

    test('should fallback to secondary repository when primary fails', () async {
      // Arrange
      when(() => mockApiWordRepository.getTranslation(word)).thenThrow(Exception('Primary failed'));
      when(() => mockFallbackTranslationRepository.getTranslation(word)).thenAnswer((_) async => translation);

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Success<Translation>>());
      expect((result as Success).result, translation);
      verify(() => mockApiWordRepository.getTranslation(word)).called(1);
      verify(() => mockFallbackTranslationRepository.getTranslation(word)).called(1);
    });

    test('should return failure when both primary and fallback repositories fail', () async {
      // Arrange
      final exception = Exception('Both failed');
      when(() => mockApiWordRepository.getTranslation(word)).thenThrow(Exception('Primary failed'));
      when(() => mockFallbackTranslationRepository.getTranslation(word)).thenThrow(exception);

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Failure>());
      expect((result as Failure).error, exception);
      verify(() => mockApiWordRepository.getTranslation(word)).called(1);
      verify(() => mockFallbackTranslationRepository.getTranslation(word)).called(1);
    });
  });
}
