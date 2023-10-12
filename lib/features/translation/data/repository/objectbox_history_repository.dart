import 'package:injectable/injectable.dart' show Injectable;
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_history_word.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/history_repository.dart';

@Injectable(as: HistoryRepository)
class ObjectboxHistoryRepository implements HistoryRepository {
  final ObjectboxStoreHolder _objectboxStoreHolder;

  ObjectboxHistoryRepository(this._objectboxStoreHolder);

  @override
  Future<Iterable<Word>> getAll(int offset) async {
    final query = _objectboxStoreHolder.historyBox
        .query()
        .order(
          ObjectboxHistoryWord_.id,
          flags: Order.descending,
        )
        .build()
      ..limit = AppConfig.wordsPerPage
      ..offset = offset;
    return query.find();
  }

  @override
  Future<int> save(Word word) async {
    final box = _objectboxStoreHolder.historyBox;
    final query = box
        .query(
          ObjectboxHistoryWord_.wordId
              .equals(
                word.wordId,
              )
              .and(
                ObjectboxHistoryWord_.langId.equals(
                  word.langId,
                ),
              ),
        )
        .build();
    final alreadyExist = query.count() > 0;
    if (alreadyExist) {
      // Remove the word to maintain history ordering.
      query.remove();
    }
    return box.put(ObjectboxHistoryWord.fromWord(word));
  }
}
