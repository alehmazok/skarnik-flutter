import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract class WordRepository {
  Future<Word?> getWord({required int langId, required wordId});
}
