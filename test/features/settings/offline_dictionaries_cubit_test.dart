import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/settings/presentation/offline_dictionaries_cubit.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/download_progress.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/check_download_rate_limit.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/clear_downloaded_dictionary.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/count_downloaded_words.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/download_dictionary.dart';

class MockDownloadDictionaryUseCase extends Mock implements DownloadDictionaryUseCase {}

class MockClearDownloadedDictionaryUseCase extends Mock
    implements ClearDownloadedDictionaryUseCase {}

class MockCountDownloadedWordsUseCase extends Mock implements CountDownloadedWordsUseCase {}

class MockCheckDownloadRateLimitUseCase extends Mock implements CheckDownloadRateLimitUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(Dictionary.tsbm);
  });

  group('OfflineDictionariesCubit', () {
    late MockDownloadDictionaryUseCase downloadDictionaryUseCase;
    late MockClearDownloadedDictionaryUseCase clearDownloadedDictionaryUseCase;
    late MockCountDownloadedWordsUseCase countDownloadedWordsUseCase;
    late MockCheckDownloadRateLimitUseCase checkDownloadRateLimitUseCase;

    setUp(() {
      downloadDictionaryUseCase = MockDownloadDictionaryUseCase();
      clearDownloadedDictionaryUseCase = MockClearDownloadedDictionaryUseCase();
      countDownloadedWordsUseCase = MockCountDownloadedWordsUseCase();
      checkDownloadRateLimitUseCase = MockCheckDownloadRateLimitUseCase();

      when(() => countDownloadedWordsUseCase(any())).thenAnswer((_) async => 0);
    });

    OfflineDictionariesCubit newInstance() => OfflineDictionariesCubit(
      downloadDictionaryUseCase: downloadDictionaryUseCase,
      clearDownloadedDictionaryUseCase: clearDownloadedDictionaryUseCase,
      countDownloadedWordsUseCase: countDownloadedWordsUseCase,
      checkDownloadRateLimitUseCase: checkDownloadRateLimitUseCase,
    );

    test('download() returns false and does not start a download when rate-limited', () async {
      when(() => checkDownloadRateLimitUseCase()).thenAnswer((_) async => false);
      final cubit = newInstance();

      final started = await cubit.download(Dictionary.tsbm);

      expect(started, false);
      verifyNever(() => downloadDictionaryUseCase(any()));
      await cubit.close();
    });

    blocTest<OfflineDictionariesCubit, Map<Dictionary, DictionaryOfflineStatus>>(
      'starts and completes a download when not rate-limited',
      setUp: () {
        when(() => checkDownloadRateLimitUseCase()).thenAnswer((_) async => true);
        when(() => downloadDictionaryUseCase(Dictionary.tsbm)).thenAnswer(
          (_) => Stream.fromIterable([const DownloadProgress(done: 5000, total: 96641)]),
        );
        // Deliberately left at the blanket 0 stub (not overridden to some
        // other value here): the cubit's own constructor-time
        // _loadDownloadedCounts() races the download under test for this
        // same mock call, so a distinguishable per-call return would make
        // this test's outcome depend on which one wins the race.
      },
      build: newInstance,
      act: (cubit) async {
        final started = await cubit.download(Dictionary.tsbm);
        expect(started, true);
        // The actual fetch/write is fire-and-forget from download()'s
        // perspective; give it a beat to run through the mocked stream.
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<Map<Dictionary, DictionaryOfflineStatus>>().having(
          (state) => state[Dictionary.tsbm],
          'tsbm status',
          isA<DictionaryDownloading>(),
        ),
        isA<Map<Dictionary, DictionaryOfflineStatus>>().having(
          (state) => state[Dictionary.tsbm],
          'tsbm status',
          isA<DictionaryDownloaded>(),
        ),
      ],
    );
  });
}
