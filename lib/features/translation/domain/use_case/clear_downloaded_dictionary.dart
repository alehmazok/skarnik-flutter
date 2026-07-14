import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/download_cursor_repository.dart';
import '../repository/local_translation_repository.dart';

@injectable
class ClearDownloadedDictionaryUseCase {
  final _logger = getLogger(ClearDownloadedDictionaryUseCase);

  final LocalTranslationRepository _localTranslationRepository;
  final DownloadCursorRepository _downloadCursorRepository;

  ClearDownloadedDictionaryUseCase(
    this._localTranslationRepository,
    this._downloadCursorRepository,
  );

  Future<UseCaseResult<bool>> call(Dictionary dictionary) async {
    try {
      await _localTranslationRepository.clear(dictionary.langId);
      await _downloadCursorRepository.clearCursor(dictionary);
      return const Success(true);
    } catch (e, st) {
      _logger.severe('Здарылася памылка падчас выдалення афлайн-слоўніка:', e, st);
      return Failure(e);
    }
  }
}
