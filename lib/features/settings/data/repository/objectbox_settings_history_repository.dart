import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';

import '../../domain/repository/settings_history_repository.dart';

@Injectable(as: SettingsHistoryRepository)
class ObjectboxSettingsHistoryRepository implements SettingsHistoryRepository {
  final ObjectboxStoreHolder _objectboxService;

  ObjectboxSettingsHistoryRepository(this._objectboxService);

  @override
  Future<bool> clear() async {
    final box = _objectboxService.historyBox;
    await box.removeAllAsync();
    return true;
  }
}
