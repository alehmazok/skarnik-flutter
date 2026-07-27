import '../entity/widget_history_entry.dart';

abstract interface class WidgetHistoryRepository {
  Future<WidgetHistoryEntry?> getEntry(int wordId);

  Future<void> saveEntry(WidgetHistoryEntry entry);
}
