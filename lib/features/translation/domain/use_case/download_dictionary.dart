import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../entity/download_progress.dart';
import '../repository/cloud_translation_repository.dart';
import '../repository/download_cursor_repository.dart';
import '../repository/local_translation_repository.dart';

@injectable
class DownloadDictionaryUseCase {
  final CloudTranslationRepository _cloudTranslationRepository;
  final LocalTranslationRepository _localTranslationRepository;
  final DownloadCursorRepository _downloadCursorRepository;

  DownloadDictionaryUseCase({
    required CloudTranslationRepository cloudTranslationRepository,
    required LocalTranslationRepository localTranslationRepository,
    required DownloadCursorRepository downloadCursorRepository,
  }) : _cloudTranslationRepository = cloudTranslationRepository,
       _localTranslationRepository = localTranslationRepository,
       _downloadCursorRepository = downloadCursorRepository;

  Stream<DownloadProgress> call(Dictionary dictionary) async* {
    final total = await _cloudTranslationRepository.countWords(dictionary);
    final localCount = await _localTranslationRepository.count(dictionary.langId);
    var startCursor = await _downloadCursorRepository.getCursor(dictionary);

    // Stale cursor: persisted resume point but nothing locally to resume
    // from (e.g. app storage partially wiped outside the app's own delete
    // flow). Resuming from it would silently skip that gap forever.
    if (startCursor > 0 && localCount == 0) {
      await _downloadCursorRepository.clearCursor(dictionary);
      startCursor = 0;
    }

    // Only trust local count as "already done" when genuinely resuming from
    // a cursor. If startCursor is 0 we're about to re-fetch from page 1 and
    // idempotently rewrite everything (safe — ObjectBox @Unique replaces in
    // place), so counting pre-existing rows here would double-count them
    // against total. This matters for a partial download that predates this
    // resume feature and has no cursor ever recorded.
    var done = startCursor > 0 ? localCount : 0;
    yield DownloadProgress(done: done, total: total);

    await for (final page in _cloudTranslationRepository.downloadDictionary(
      dictionary,
      startCursor: startCursor,
    )) {
      await _localTranslationRepository.putMany(dictionary.langId, page.words);
      done += page.words.length;
      await _downloadCursorRepository.setCursor(dictionary, page.cursor);
      yield DownloadProgress(done: done, total: total);
    }

    await _downloadCursorRepository.clearCursor(dictionary);
  }
}
