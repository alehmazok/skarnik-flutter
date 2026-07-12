import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/download_rate_limit_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/check_download_rate_limit.dart';

class MockDownloadRateLimitRepository extends Mock implements DownloadRateLimitRepository {}

void main() {
  late CheckDownloadRateLimitUseCase useCase;
  late MockDownloadRateLimitRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(<DateTime>[]);
  });

  setUp(() {
    mockRepository = MockDownloadRateLimitRepository();
    useCase = CheckDownloadRateLimitUseCase(mockRepository);
    when(() => mockRepository.saveRecentAttempts(any())).thenAnswer((_) async {});
  });

  group('CheckDownloadRateLimitUseCase', () {
    test('allows and records the attempt when there is no prior history', () async {
      when(() => mockRepository.getRecentAttempts()).thenAnswer((_) async => []);

      expect(await useCase(), true);
      final saved =
          verify(() => mockRepository.saveRecentAttempts(captureAny())).captured.single
              as List<DateTime>;
      expect(saved.length, 1);
    });

    test(
      'allows when below the threshold within the window',
      () async {
        final now = DateTime.now();
        when(() => mockRepository.getRecentAttempts()).thenAnswer(
          (_) async => [
            now.subtract(const Duration(minutes: 1)),
            now.subtract(const Duration(minutes: 2)),
            now.subtract(const Duration(minutes: 3)),
          ],
        );

        expect(await useCase(), true);
      },
    );

    test('blocks and does not add a new attempt once the threshold is reached', () async {
      final now = DateTime.now();
      when(() => mockRepository.getRecentAttempts()).thenAnswer(
        (_) async => List.generate(
          AppConfig.downloadMaxAttemptsPerWindow,
          (i) => now.subtract(Duration(seconds: i * 10)),
        ),
      );

      expect(await useCase(), false);
      final saved =
          verify(() => mockRepository.saveRecentAttempts(captureAny())).captured.single
              as List<DateTime>;
      expect(saved.length, AppConfig.downloadMaxAttemptsPerWindow);
    });

    test('attempts outside the window are pruned and do not count toward the limit', () async {
      final now = DateTime.now();
      when(() => mockRepository.getRecentAttempts()).thenAnswer(
        (_) async => List.generate(
          AppConfig.downloadMaxAttemptsPerWindow,
          (_) => now.subtract(AppConfig.downloadRateLimitWindow * 2),
        ),
      );

      expect(await useCase(), true);
      final saved =
          verify(() => mockRepository.saveRecentAttempts(captureAny())).captured.single
              as List<DateTime>;
      expect(saved.length, 1);
    });
  });
}
