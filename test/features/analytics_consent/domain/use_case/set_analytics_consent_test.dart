import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/repository/analytics_consent_repository.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/use_case/set_analytics_consent.dart';

class MockAnalyticsConsentRepository extends Mock implements AnalyticsConsentRepository {}

void main() {
  late SetAnalyticsConsentUseCase useCase;
  late MockAnalyticsConsentRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsConsentRepository();
    useCase = SetAnalyticsConsentUseCase(mockRepository);
  });

  group('SetAnalyticsConsentUseCase', () {
    test('returns Success and persists granted=true', () async {
      when(() => mockRepository.setConsent(true)).thenAnswer((_) async {});

      final result = await useCase.call(true);

      expect(result, isA<Success<void>>());
      verify(() => mockRepository.setConsent(true)).called(1);
    });

    test('returns Success and persists granted=false', () async {
      when(() => mockRepository.setConsent(false)).thenAnswer((_) async {});

      final result = await useCase.call(false);

      expect(result, isA<Success<void>>());
      verify(() => mockRepository.setConsent(false)).called(1);
    });

    test('returns Failure when the repository throws', () async {
      when(() => mockRepository.setConsent(any())).thenThrow(Exception('boom'));

      final result = await useCase.call(true);

      expect(result, isA<Failure<void>>());
    });
  });
}
