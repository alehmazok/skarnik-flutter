import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/repository/analytics_consent_repository.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/use_case/init_analytics_consent.dart';

class MockAnalyticsConsentRepository extends Mock implements AnalyticsConsentRepository {}

void main() {
  late InitAnalyticsConsentUseCase useCase;
  late MockAnalyticsConsentRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsConsentRepository();
    useCase = InitAnalyticsConsentUseCase(mockRepository);
  });

  group('InitAnalyticsConsentUseCase', () {
    test('returns Success and applies the stored consent', () async {
      when(() => mockRepository.applyStoredConsent()).thenAnswer((_) async {});

      final result = await useCase.call();

      expect(result, isA<Success<void>>());
      verify(() => mockRepository.applyStoredConsent()).called(1);
    });

    test('returns Failure when the repository throws', () async {
      when(() => mockRepository.applyStoredConsent()).thenThrow(Exception('boom'));

      final result = await useCase.call();

      expect(result, isA<Failure<void>>());
    });
  });
}
