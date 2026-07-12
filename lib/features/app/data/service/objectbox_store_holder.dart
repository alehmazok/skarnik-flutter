import 'package:skarnik_flutter/objectbox.g.dart';

import '../model/objectbox_favorite_word.dart';
import '../model/objectbox_history_word.dart';
import '../model/objectbox_search_word.dart';
import '../model/objectbox_translation_word.dart';

/// Manually registered as a dependency in [ObjectboxDatabaseRepository].
class ObjectboxStoreHolder {
  final Store searchStore;
  final Store historyStore;
  final Store translationStore;

  Box<ObjectboxSearchWord> get searchBox => searchStore.box<ObjectboxSearchWord>();

  Box<ObjectboxHistoryWord> get historyBox => historyStore.box<ObjectboxHistoryWord>();

  Box<ObjectboxFavoriteWord> get favoritesBox => historyStore.box<ObjectboxFavoriteWord>();

  Box<ObjectboxTranslationWord> get translationBox =>
      translationStore.box<ObjectboxTranslationWord>();

  ObjectboxStoreHolder({
    required this.searchStore,
    required this.historyStore,
    required this.translationStore,
  });
}
