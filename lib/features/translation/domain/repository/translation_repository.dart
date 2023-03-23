import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../entity/translation.dart';

abstract class TranslationRepository {
  Future<Translation> getTranslation(Word word);
}
