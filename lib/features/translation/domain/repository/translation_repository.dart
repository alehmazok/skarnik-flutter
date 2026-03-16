import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../entity/api_word.dart';
import '../entity/translation.dart';

abstract interface class TranslationRepository {
  Future<Translation> getTranslation(Word word);

  Future<ApiWord> getWord(Word word);
}
