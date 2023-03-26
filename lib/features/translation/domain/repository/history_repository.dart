import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

abstract class HistoryRepository {
  Future<int> save(Word word);
}
