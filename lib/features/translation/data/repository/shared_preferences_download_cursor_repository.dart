import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../../domain/repository/download_cursor_repository.dart';

@Injectable(as: DownloadCursorRepository)
class SharedPreferencesDownloadCursorRepository implements DownloadCursorRepository {
  static const _keyPrefix = 'download_cursor_';

  final _prefs = SharedPreferencesAsync();

  String _key(Dictionary dictionary) => '$_keyPrefix${dictionary.path}';

  @override
  Future<int> getCursor(Dictionary dictionary) async => await _prefs.getInt(_key(dictionary)) ?? 0;

  @override
  Future<void> setCursor(Dictionary dictionary, int cursor) =>
      _prefs.setInt(_key(dictionary), cursor);

  @override
  Future<void> clearCursor(Dictionary dictionary) => _prefs.remove(_key(dictionary));
}
