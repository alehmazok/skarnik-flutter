import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract class AnalyticsVocabularyRepository {
  const AnalyticsVocabularyRepository._();

  Future<void> logWord(Word word);
}
