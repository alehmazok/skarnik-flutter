import '../entity/stress_row.dart';
import '../entity/stress_word_entry.dart';

abstract interface class StressRepository {
  Future<List<StressWordEntry>> resolveWordList(String word);

  Future<List<StressRow>> getStressTable(int wordId);
}
