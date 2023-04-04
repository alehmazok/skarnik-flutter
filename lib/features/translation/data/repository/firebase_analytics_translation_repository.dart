import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';

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
  Future<void> logShare(Translation translation) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logShare(
      contentType: ContentType.text.mimeType,
      itemId: translation.uri.toString(),
      method: 'system',
    );
  }
}
