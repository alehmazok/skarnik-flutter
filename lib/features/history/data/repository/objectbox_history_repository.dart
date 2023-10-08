import 'package:injectable/injectable.dart' show Injectable;
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/history_repository.dart';

@Injectable(as: HistoryRepository)
class ObjectboxHistoryRepository implements HistoryRepository {
  final ObjectboxStoreHolder _objectboxService;

  ObjectboxHistoryRepository(this._objectboxService);

  @override
  Future<Iterable<Word>> getAll(int offset) async {
    final query = _objectboxService.historyBox
        .query()
        .order(ObjectboxHistoryWord_.id, flags: Order.descending)
        .build()
      ..limit = AppConfig.historyWordsPerPageLimit
      ..offset = offset;
    return query.findAsync();
  }
}
