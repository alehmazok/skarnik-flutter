import '../entity/api_word.dart';

abstract interface class LocalTranslationRepository {
  Future<ApiWord?> getWord({required int langId, required int wordId});

  Future<void> putMany(int langId, List<ApiWord> words);

  Future<int> count(int langId);

  Future<void> clear(int langId);
}
