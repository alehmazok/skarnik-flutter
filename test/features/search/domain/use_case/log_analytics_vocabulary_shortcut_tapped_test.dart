import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/search/domain/repository/analytics_search_repository.dart';
import 'package:skarnik_flutter/features/search/domain/use_case/log_analytics_vocabulary_shortcut_tapped.dart';

class MockAnalyticsSearchRepository extends Mock implements AnalyticsSearchRepository {}

void main() {
  late LogAnalyticsVocabularyShortcutTappedUseCase useCase;
  late MockAnalyticsSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsSearchRepository();
    useCase = LogAnalyticsVocabularyShortcutTappedUseCase(mockRepository);
  });

  group('LogAnalyticsVocabularyShortcutTappedUseCase', () {
    test('should return Success when repository call succeeds', () async {
      when(() => mockRepository.logVocabularyShortcutTapped()).thenAnswer((_) async => {});

      final result = await useCase.call();

      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logVocabularyShortcutTapped()).called(1);
    });

    test('should return Success even when repository throws an exception', () async {
      when(
        () => mockRepository.logVocabularyShortcutTapped(),
      ).thenThrow(Exception('Network error'));

      final result = await useCase.call();

      expect(result, isA<Success<bool>>());
      expect((result as Success).result, true);
      verify(() => mockRepository.logVocabularyShortcutTapped()).called(1);
    });
  });
}
