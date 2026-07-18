import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/review/domain/repository/review_repository.dart';
import 'package:skarnik_flutter/features/review/domain/use_case/check_and_request_review.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late CheckAndRequestReviewUseCase useCase;
  late MockReviewRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewRepository();
    useCase = CheckAndRequestReviewUseCase(mockRepository);
  });

  group('CheckAndRequestReviewUseCase', () {
    test('returns notEligible and does nothing else when already requested', () async {
      when(() => mockRepository.isReviewAlreadyRequested()).thenAnswer((_) async => true);

      final result = await useCase.call();

      expect(result, isA<Success<ReviewOutcome>>());
      expect((result as Success).result, ReviewOutcome.notEligible);
      verifyNever(() => mockRepository.incrementAndGetTranslationViewCount());
      verifyNever(() => mockRepository.markReviewRequested());
      verifyNever(() => mockRepository.requestReview());
    });

    test('returns notEligible and does not request review when below threshold', () async {
      when(() => mockRepository.isReviewAlreadyRequested()).thenAnswer((_) async => false);
      when(
        () => mockRepository.incrementAndGetTranslationViewCount(),
      ).thenAnswer((_) async => AppConfig.reviewRequestViewThreshold - 1);

      final result = await useCase.call();

      expect(result, isA<Success<ReviewOutcome>>());
      expect((result as Success).result, ReviewOutcome.notEligible);
      verifyNever(() => mockRepository.markReviewRequested());
      verifyNever(() => mockRepository.requestReview());
    });

    test(
      'marks requested and requests review, in order, when threshold reached',
      () async {
        when(() => mockRepository.isReviewAlreadyRequested()).thenAnswer((_) async => false);
        when(
          () => mockRepository.incrementAndGetTranslationViewCount(),
        ).thenAnswer((_) async => AppConfig.reviewRequestViewThreshold);
        when(() => mockRepository.markReviewRequested()).thenAnswer((_) async {});
        when(() => mockRepository.requestReview()).thenAnswer((_) async => true);

        final result = await useCase.call();

        expect(result, isA<Success<ReviewOutcome>>());
        expect((result as Success).result, ReviewOutcome.shown);
        verifyInOrder([
          () => mockRepository.markReviewRequested(),
          () => mockRepository.requestReview(),
        ]);
      },
    );

    test('returns unavailable when native review prompt cannot be shown', () async {
      when(() => mockRepository.isReviewAlreadyRequested()).thenAnswer((_) async => false);
      when(
        () => mockRepository.incrementAndGetTranslationViewCount(),
      ).thenAnswer((_) async => AppConfig.reviewRequestViewThreshold);
      when(() => mockRepository.markReviewRequested()).thenAnswer((_) async {});
      when(() => mockRepository.requestReview()).thenAnswer((_) async => false);

      final result = await useCase.call();

      expect(result, isA<Success<ReviewOutcome>>());
      expect((result as Success).result, ReviewOutcome.unavailable);
    });

    test('returns notEligible when repository throws', () async {
      when(() => mockRepository.isReviewAlreadyRequested()).thenThrow(Exception('boom'));

      final result = await useCase.call();

      expect(result, isA<Success<ReviewOutcome>>());
      expect((result as Success).result, ReviewOutcome.notEligible);
    });
  });
}
