import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../../domain/entity/translation.dart';
import '../../domain/repository/analytics_translation_repository.dart';

@prod
@Injectable(as: AnalyticsTranslationRepository)
class FirebaseAnalyticsTranslationRepository implements AnalyticsTranslationRepository {
  @override
  Future<void> logTranslation(Translation translation) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
      name: 'translation',
      parameters: {
        'uri': translation.uri.toString(),
        'word_id': translation.word.wordId,
        'lang_id': translation.word.langId,
        'word': translation.word.word,
        'dict_name': translation.word.dictName,
        'dict_path': translation.word.dictPath,
      },
    );
  }

  @override
  Future<void> logShare(String itemId) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logShare(
      contentType: ContentType.text.mimeType,
      itemId: itemId,
      method: 'system',
    );
  }

  @override
  Future<void> logAddToFavorites(Word word) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
      name: 'add_to_favorites',
      parameters: {
        'word_id': word.wordId,
        'lang_id': word.langId,
        'word': word.word,
        'dict_name': word.dictName,
        'dict_path': word.dictPath,
      },
    );
  }
}
