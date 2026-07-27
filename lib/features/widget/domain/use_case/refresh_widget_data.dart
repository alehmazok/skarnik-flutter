import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/widget_history_entry.dart';
import '../entity/word_of_the_day.dart';
import '../repository/widget_history_repository.dart';
import '../util/html_to_plain_text.dart';
import '../util/word_similarity.dart' as word_similarity;
import 'pick_random_word.dart';

/// Orchestrates the "Слова дня" refresh: pick a random bel_rus word, skip
/// ones recently shown, fetch its translation, reject near-identical
/// word/translation pairs, and retry — spec §3, max 30 attempts per refresh.
@injectable
class RefreshWidgetDataUseCase {
  static const maxAttempts = 30;
  static const _reuseThreshold = Duration(days: 30);

  static const fallback = WordOfTheDay(wordId: -1, word: 'халэмус', translation: 'гибель, конец');

  final _logger = getLogger(RefreshWidgetDataUseCase);

  final PickRandomWordUseCase _pickRandomWord;
  final WidgetHistoryRepository _historyRepository;
  final GetTranslationUseCase _getTranslation;

  RefreshWidgetDataUseCase(this._pickRandomWord, this._historyRepository, this._getTranslation);

  Future<WordOfTheDay> call() async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final word = _pickRandomWord();

      final existing = await _historyRepository.getEntry(word.wordId);
      if (existing != null && !_isReusable(existing)) {
        continue;
      }

      final result = await _getTranslation(word);
      switch (result) {
        case Failure():
          _logger.warning('Не атрымалася атрымаць пераклад для слова ${word.wordId}.');
          continue;
        case Success(result: final translation):
          final plainText = htmlToPlainText(translation.html);
          final isSimilar = word_similarity.isSimilar(word.word, translation.html);
          await _historyRepository.saveEntry(
            WidgetHistoryEntry(
              wordId: word.wordId,
              word: word.word,
              translation: plainText,
              createdAt: DateTime.now(),
              isSimilar: isSimilar,
            ),
          );
          if (isSimilar) {
            continue;
          }
          return WordOfTheDay(wordId: word.wordId, word: word.word, translation: plainText);
      }
    }

    _logger.warning('Вычарпаны ліміт спроб ($maxAttempts), выкарыстоўваем слова па змаўчанні.');
    return fallback;
  }

  /// Shown within the last month -> always treated as seen, skip. Shown
  /// earlier -> reusable only if it wasn't flagged similar back then.
  bool _isReusable(WidgetHistoryEntry entry) {
    final age = DateTime.now().difference(entry.createdAt);
    if (age < _reuseThreshold) return false;
    return !entry.isSimilar;
  }
}
