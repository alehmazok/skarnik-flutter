import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

abstract interface class DownloadCursorRepository {
  /// Last successfully persisted cloud row id for [dictionary], or 0 if no
  /// download is in progress / resumable.
  Future<int> getCursor(Dictionary dictionary);

  Future<void> setCursor(Dictionary dictionary, int cursor);

  Future<void> clearCursor(Dictionary dictionary);
}
