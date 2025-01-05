import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../entity/translation.dart';

abstract interface class TranslationRepository {
  Future<Translation> getTranslation(Word word);
}

abstract interface class FallbackTranslationRepository implements TranslationRepository {}
