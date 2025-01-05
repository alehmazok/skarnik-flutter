import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../entity/api_word.dart';

abstract interface class ApiTranslationRepository {
  Future<ApiWord> getTranslation(Word word);
}
