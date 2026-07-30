import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/repository/analytics_consent_repository.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/use_case/set_analytics_consent.dart';
import 'package:skarnik_flutter/features/analytics_consent/presentation/analytics_consent_cubit.dart';

class MockAnalyticsConsentRepository extends Mock implements AnalyticsConsentRepository {}

class MockSetAnalyticsConsentUseCase extends Mock implements SetAnalyticsConsentUseCase {}

void main() {
  group('AnalyticsConsentCubit', () {
    late MockAnalyticsConsentRepository repository;
    late MockSetAnalyticsConsentUseCase setAnalyticsConsentUseCase;

    setUp(() {
      repository = MockAnalyticsConsentRepository();
      setAnalyticsConsentUseCase = MockSetAnalyticsConsentUseCase();
    });

    AnalyticsConsentCubit newInstance() =>
        AnalyticsConsentCubit(repository, setAnalyticsConsentUseCase);

    blocTest<AnalyticsConsentCubit, AnalyticsConsentState?>(
      'loads hasAnswered=false, granted=false on construction when never answered',
      setUp: () {
        when(() => repository.hasAnswered()).thenAnswer((_) async => false);
        when(() => repository.isGranted()).thenAnswer((_) async => false);
      },
      build: newInstance,
      expect: () => [(hasAnswered: false, granted: false)],
    );

    blocTest<AnalyticsConsentCubit, AnalyticsConsentState?>(
      'loads the previously stored answer',
      setUp: () {
        when(() => repository.hasAnswered()).thenAnswer((_) async => true);
        when(() => repository.isGranted()).thenAnswer((_) async => true);
      },
      build: newInstance,
      expect: () => [(hasAnswered: true, granted: true)],
    );

    // Plain tests (not blocTest) below: blocTest's `build` must return the
    // bloc synchronously, so it can't await the constructor's
    // scheduleMicrotask(_load) settling before `act` runs `setConsent` —
    // that race made emission order across the two calls undefined.
    test('setConsent(true) applies consent and emits answered=true, granted=true', () async {
      when(() => repository.hasAnswered()).thenAnswer((_) async => false);
      when(() => repository.isGranted()).thenAnswer((_) async => false);
      when(
        () => setAnalyticsConsentUseCase(true),
      ).thenAnswer((_) async => const Success(null));

      final cubit = newInstance();
      await Future<void>.delayed(Duration.zero);

      final expectation = expectLater(
        cubit.stream,
        emits((hasAnswered: true, granted: true)),
      );
      await cubit.setConsent(true);
      await expectation;

      verify(() => setAnalyticsConsentUseCase(true)).called(1);
    });

    test('setConsent(false) emits answered=true, granted=false', () async {
      when(() => repository.hasAnswered()).thenAnswer((_) async => false);
      when(() => repository.isGranted()).thenAnswer((_) async => false);
      when(
        () => setAnalyticsConsentUseCase(false),
      ).thenAnswer((_) async => const Success(null));

      final cubit = newInstance();
      await Future<void>.delayed(Duration.zero);

      final expectation = expectLater(
        cubit.stream,
        emits((hasAnswered: true, granted: false)),
      );
      await cubit.setConsent(false);
      await expectation;
    });
  });
}
