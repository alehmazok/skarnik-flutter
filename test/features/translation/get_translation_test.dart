import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/data/model/api_word_model.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/api_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/cloud_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/website_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart';

class MockApiWordRepository extends Mock implements ApiTranslationRepository {}

class MockCloudTranslationRepository extends Mock implements CloudTranslationRepository {}

class MockWebsiteTranslationRepository extends Mock implements WebsiteTranslationRepository {}

class MockWord extends Mock implements Word {}

void main() {
  late GetTranslationUseCase useCase;
  late MockApiWordRepository mockApiWordRepository;
  late MockCloudTranslationRepository mockCloudTranslationRepository;
  late MockWebsiteTranslationRepository mockWebsiteTranslationRepository;

  setUp(() {
    mockApiWordRepository = MockApiWordRepository();
    mockCloudTranslationRepository = MockCloudTranslationRepository();
    mockWebsiteTranslationRepository = MockWebsiteTranslationRepository();
    useCase = GetTranslationUseCase(
      apiWordRepository: mockApiWordRepository,
      cloudTranslationRepository: mockCloudTranslationRepository,
      websiteTranslationRepository: mockWebsiteTranslationRepository,
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
    });

    test('should return ApiWord from the API repository when successful', () async {
      translation = Translation.build(
        uri: word.buildApiUri(),
        html: '<div></div>',
        word: word,
        source: 'api',
      );

      // Arrange
      when(
        () => mockApiWordRepository.getWord(word),
      ).thenAnswer(
        (_) async => apiWord.toEntity(),
      );

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Success<Translation>>());
      expect((result as Success).result, translation);
      verify(() => mockApiWordRepository.getWord(word)).called(1);
      verifyNever(() => mockCloudTranslationRepository.getWord(word));
      verifyNever(() => mockWebsiteTranslationRepository.getTranslation(word));
    });

    test('should fallback to Cloud repository when API fails', () async {
      translation = Translation.build(
        uri: word.buildApiUri(),
        html: '<div></div>',
        word: word,
        source: 'cloud',
      );

      // Arrange
      when(() => mockApiWordRepository.getWord(word)).thenThrow(Exception('API failed'));
      when(
        () => mockCloudTranslationRepository.getWord(word),
      ).thenAnswer((_) async => apiWord.toEntity());

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Success<Translation>>());
      expect((result as Success).result, translation);
      verify(() => mockApiWordRepository.getWord(word)).called(1);
      verify(() => mockCloudTranslationRepository.getWord(word)).called(1);
      verifyNever(() => mockWebsiteTranslationRepository.getTranslation(word));
    });

    test('should fallback to Websote repository when API and Cloud fail', () async {
      translation = Translation.build(
        uri: word.buildApiUri(),
        html: '<div></div>',
        word: word,
        source: 'cloud',
      );

      // Arrange
      when(() => mockApiWordRepository.getWord(word)).thenThrow(Exception('API failed'));
      when(() => mockCloudTranslationRepository.getWord(word)).thenThrow(Exception('Cloud failed'));
      when(
        () => mockWebsiteTranslationRepository.getTranslation(word),
      ).thenAnswer((_) async => translation);

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Success<Translation>>());
      expect((result as Success).result, translation);
      verify(() => mockApiWordRepository.getWord(word)).called(1);
      verify(() => mockCloudTranslationRepository.getWord(word)).called(1);
      verify(() => mockWebsiteTranslationRepository.getTranslation(word)).called(1);
    });

    test('should return failure when both primary and fallback repositories fail', () async {
      // Arrange
      final exception = Exception('All failed');
      when(() => mockApiWordRepository.getWord(word)).thenThrow(Exception('API failed'));
      when(
        () => mockCloudTranslationRepository.getWord(word),
      ).thenThrow(Exception('Cloud failed'));
      when(() => mockWebsiteTranslationRepository.getTranslation(word)).thenThrow(exception);

      // Act
      final result = await useCase.call(word);

      // Assert
      expect(result, isA<Failure>());
      expect((result as Failure).error, exception);
      verify(() => mockApiWordRepository.getWord(word)).called(1);
      verify(() => mockCloudTranslationRepository.getWord(word)).called(1);
      verify(() => mockWebsiteTranslationRepository.getTranslation(word)).called(1);
    });
  });
}
