import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart';

class MockPrimaryTranslationRepository extends Mock implements PrimaryTranslationRepository {}

class MockFallbackTranslationRepository extends Mock implements FallbackTranslationRepository {}

class MockWord extends Mock implements Word {}

void main() {
  late GetTranslationUseCase useCase;
  late MockPrimaryTranslationRepository mockPrimaryTranslationRepository;
  late MockFallbackTranslationRepository mockFallbackTranslationRepository;

  setUp(() {
    mockPrimaryTranslationRepository = MockPrimaryTranslationRepository();
    mockFallbackTranslationRepository = MockFallbackTranslationRepository();
    useCase = GetTranslationUseCase(
      primaryTranslationRepository: mockPrimaryTranslationRepository,
      fallbackTranslationRepository: mockFallbackTranslationRepository,
    );
  });

  group('GetTranslationUseCase', () {
    final word = MockWord();

    final translation = Translation.build(
      uri: Uri.parse('https://skarnik.by/belrus/1'),
      html: '<div></div>',
      word: word,
    );

    test('should return translation from primary repository when successful', () async {
      // Arrange
      when(() => mockPrimaryTranslationRepository.getTranslation(word)).thenAnswer((_) async => translation);

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Success<Translation>>());
      expect((result as Success).result, translation);
      verify(() => mockPrimaryTranslationRepository.getTranslation(word)).called(1);
      verifyNever(() => mockFallbackTranslationRepository.getTranslation(word));
    });

    test('should fallback to secondary repository when primary fails', () async {
      // Arrange
      when(() => mockPrimaryTranslationRepository.getTranslation(word)).thenThrow(Exception('Primary failed'));
      when(() => mockFallbackTranslationRepository.getTranslation(word)).thenAnswer((_) async => translation);

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Success<Translation>>());
      expect((result as Success).result, translation);
      verify(() => mockPrimaryTranslationRepository.getTranslation(word)).called(1);
      verify(() => mockFallbackTranslationRepository.getTranslation(word)).called(1);
    });

    test('should return failure when both primary and fallback repositories fail', () async {
      // Arrange
      final exception = Exception('Both failed');
      when(() => mockPrimaryTranslationRepository.getTranslation(word)).thenThrow(Exception('Primary failed'));
      when(() => mockFallbackTranslationRepository.getTranslation(word)).thenThrow(exception);

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Failure>());
      expect((result as Failure).error, exception);
      verify(() => mockPrimaryTranslationRepository.getTranslation(word)).called(1);
      verify(() => mockFallbackTranslationRepository.getTranslation(word)).called(1);
    });
  });
}
