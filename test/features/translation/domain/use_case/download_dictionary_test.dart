import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/api_word.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/download_page.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/download_progress.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/cloud_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/download_cursor_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/local_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/download_dictionary.dart';

class MockCloudTranslationRepository extends Mock implements CloudTranslationRepository {}

class MockLocalTranslationRepository extends Mock implements LocalTranslationRepository {}

class MockDownloadCursorRepository extends Mock implements DownloadCursorRepository {}

ApiWord _word(int id) => ApiWord(externalId: id, translation: 'w$id', redirectTo: null);

void main() {
  const dictionary = Dictionary.tsbm;

  late MockCloudTranslationRepository cloudRepo;
  late MockLocalTranslationRepository localRepo;
  late MockDownloadCursorRepository cursorRepo;
  late DownloadDictionaryUseCase useCase;

  setUpAll(() {
    registerFallbackValue(dictionary);
  });

  setUp(() {
    cloudRepo = MockCloudTranslationRepository();
    localRepo = MockLocalTranslationRepository();
    cursorRepo = MockDownloadCursorRepository();
    useCase = DownloadDictionaryUseCase(
      cloudTranslationRepository: cloudRepo,
      localTranslationRepository: localRepo,
      downloadCursorRepository: cursorRepo,
    );

    when(() => localRepo.putMany(any(), any())).thenAnswer((_) async {});
    when(() => cursorRepo.setCursor(any(), any())).thenAnswer((_) async {});
    when(() => cursorRepo.clearCursor(any())).thenAnswer((_) async {});
  });

  group('fresh download (no cursor)', () {
    setUp(() {
      when(() => cloudRepo.countWords(dictionary)).thenAnswer((_) async => 2);
      when(() => localRepo.count(dictionary.langId)).thenAnswer((_) async => 0);
      when(() => cursorRepo.getCursor(dictionary)).thenAnswer((_) async => 0);
      when(
        () => cloudRepo.downloadDictionary(dictionary, startCursor: 0),
      ).thenAnswer((_) => Stream.value(DownloadPage(words: [_word(1), _word(2)], cursor: 2)));
    });

    test('starts done at 0 and passes startCursor 0 through', () async {
      final progress = await useCase(dictionary).toList();

      expect(progress.first, const DownloadProgress(done: 0, total: 2));
      expect(progress.last, const DownloadProgress(done: 2, total: 2));
      verify(() => cloudRepo.downloadDictionary(dictionary, startCursor: 0)).called(1);
    });

    test('persists cursor after the page and clears it on completion', () async {
      await useCase(dictionary).drain<void>();

      verify(() => cursorRepo.setCursor(dictionary, 2)).called(1);
      verify(() => cursorRepo.clearCursor(dictionary)).called(1);
    });
  });

  test('resumed download starts done at local count and passes startCursor through', () async {
    when(() => cloudRepo.countWords(dictionary)).thenAnswer((_) async => 5);
    when(() => localRepo.count(dictionary.langId)).thenAnswer((_) async => 3);
    when(() => cursorRepo.getCursor(dictionary)).thenAnswer((_) async => 300);
    when(
      () => cloudRepo.downloadDictionary(dictionary, startCursor: 300),
    ).thenAnswer((_) => Stream.value(DownloadPage(words: [_word(4), _word(5)], cursor: 500)));

    final progress = await useCase(dictionary).toList();

    expect(progress.first, const DownloadProgress(done: 3, total: 5));
    expect(progress.last, const DownloadProgress(done: 5, total: 5));
    verify(() => cloudRepo.downloadDictionary(dictionary, startCursor: 300)).called(1);
    // The mocked stream completes after one page, same as the real repo
    // signaling "no more pages" — so the download is considered finished.
    verify(() => cursorRepo.clearCursor(dictionary)).called(1);
  });

  test(
    'stale cursor (persisted but nothing locally) is cleared and download restarts from 0',
    () async {
      when(() => cloudRepo.countWords(dictionary)).thenAnswer((_) async => 2);
      when(() => localRepo.count(dictionary.langId)).thenAnswer((_) async => 0);
      when(() => cursorRepo.getCursor(dictionary)).thenAnswer((_) async => 300);
      when(
        () => cloudRepo.downloadDictionary(dictionary, startCursor: 0),
      ).thenAnswer((_) => Stream.value(DownloadPage(words: [_word(1), _word(2)], cursor: 2)));

      final progress = await useCase(dictionary).toList();

      expect(progress.first, const DownloadProgress(done: 0, total: 2));
      verify(() => cursorRepo.clearCursor(dictionary)).called(2);
      verify(() => cloudRepo.downloadDictionary(dictionary, startCursor: 0)).called(1);
    },
  );

  test(
    'pre-fix partial local data with no cursor does not double-count against total',
    () async {
      when(() => cloudRepo.countWords(dictionary)).thenAnswer((_) async => 5);
      when(() => localRepo.count(dictionary.langId)).thenAnswer((_) async => 3);
      when(() => cursorRepo.getCursor(dictionary)).thenAnswer((_) async => 0);
      when(
        () => cloudRepo.downloadDictionary(dictionary, startCursor: 0),
      ).thenAnswer((_) => Stream.value(DownloadPage(words: [_word(1), _word(2)], cursor: 2)));

      final progress = await useCase(dictionary).toList();

      expect(progress.first, const DownloadProgress(done: 0, total: 5));
    },
  );

  test('cursor is not cleared when the download stream throws', () async {
    when(() => cloudRepo.countWords(dictionary)).thenAnswer((_) async => 2);
    when(() => localRepo.count(dictionary.langId)).thenAnswer((_) async => 0);
    when(() => cursorRepo.getCursor(dictionary)).thenAnswer((_) async => 0);
    when(
      () => cloudRepo.downloadDictionary(dictionary, startCursor: 0),
    ).thenAnswer((_) => Stream.error(Exception('boom')));

    await expectLater(useCase(dictionary), emitsInOrder([anything, emitsError(isException)]));
    verifyNever(() => cursorRepo.clearCursor(dictionary));
  });
}
