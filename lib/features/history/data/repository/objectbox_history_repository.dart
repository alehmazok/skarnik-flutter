import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../../domain/repository/history_repository.dart';

@Injectable(as: HistoryRepository)
class ObjectboxHistoryRepository implements HistoryRepository {
  final ObjectboxService _objectboxService;

  ObjectboxHistoryRepository(this._objectboxService);

  @override
  Future<Iterable<Word>> getAll() async {
    return _objectboxService.historyBox.getAll();
  }
}
