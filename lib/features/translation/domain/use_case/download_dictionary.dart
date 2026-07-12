import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../entity/download_progress.dart';
import '../repository/cloud_translation_repository.dart';
import '../repository/local_translation_repository.dart';

@injectable
class DownloadDictionaryUseCase {
  final CloudTranslationRepository _cloudTranslationRepository;
  final LocalTranslationRepository _localTranslationRepository;

  DownloadDictionaryUseCase({
    required CloudTranslationRepository cloudTranslationRepository,
    required LocalTranslationRepository localTranslationRepository,
  }) : _cloudTranslationRepository = cloudTranslationRepository,
       _localTranslationRepository = localTranslationRepository;

  Stream<DownloadProgress> call(Dictionary dictionary) async* {
    final total = await _cloudTranslationRepository.countWords(dictionary);
    var done = 0;
    yield DownloadProgress(done: done, total: total);

    await for (final page in _cloudTranslationRepository.downloadDictionary(dictionary)) {
      await _localTranslationRepository.putMany(dictionary.langId, page);
      done += page.length;
      yield DownloadProgress(done: done, total: total);
    }
  }
}
