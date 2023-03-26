import 'package:skarnik_flutter/objectbox.g.dart';

import '../model/objectbox_history_word.dart';
import '../model/objectbox_search_word.dart';

class ObjectboxService {
  final Store searchStore;
  final Store historyStore;

  Box<ObjectboxSearchWord> get searchBox => searchStore.box<ObjectboxSearchWord>();

  Box<ObjectboxHistoryWord> get historyBox => historyStore.box<ObjectboxHistoryWord>();

  ObjectboxService({
    required this.searchStore,
    required this.historyStore,
  });
}
