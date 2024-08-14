import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../../domain/repository/analytics_vocabulary_repository.dart';

@prod
@Injectable(as: AnalyticsVocabularyRepository)
class FirebaseAnalyticsVocabularyRepository implements AnalyticsVocabularyRepository {
  @override
  Future<void> logWord(Word word) async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logEvent(
      name: 'vocabulary',
      parameters: {
        'word_id': word.wordId,
        'lang_id': word.langId,
        'word': word.word,
        'dict_name': word.dictionary.name,
        'dict_path': word.dictionary.path,
      },
    );
  }
}
