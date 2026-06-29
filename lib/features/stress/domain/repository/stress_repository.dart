import '../entity/stress_row.dart';

abstract interface class StressRepository {
  Future<int?> resolveWordId(String word);

  Future<List<StressRow>> getStressTable(int wordId);
}
