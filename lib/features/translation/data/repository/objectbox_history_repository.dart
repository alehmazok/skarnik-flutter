import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_history_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/history_repository.dart';

@Injectable(as: HistoryRepository)
class ObjectboxHistoryRepository implements HistoryRepository {
  final ObjectboxStoreHolder objectboxService;

  ObjectboxHistoryRepository(this.objectboxService);

  @override
  Future<int> save(Word word) async {
    final box = objectboxService.historyBox;
    final query = box.query(ObjectboxHistoryWord_.wordId.equals(word.wordId)).build();
    final alreadyExist = query.count() > 0;
    if (alreadyExist) {
      // Remove the word to maintain history ordering.
      query.remove();
    }
    return box.put(ObjectboxHistoryWord.fromWord(word));
  }
}
