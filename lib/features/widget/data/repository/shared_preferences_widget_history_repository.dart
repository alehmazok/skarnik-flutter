import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entity/widget_history_entry.dart';
import '../../domain/repository/widget_history_repository.dart';

/// Widget-local history store — separate from the app's own
/// `ObjectboxHistoryRepository`, per spec §4 (no sharing expected between the
/// widget and the main app).
@Injectable(as: WidgetHistoryRepository)
class SharedPreferencesWidgetHistoryRepository implements WidgetHistoryRepository {
  static const _key = 'widget_word_history_v1';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<WidgetHistoryEntry?> getEntry(int wordId) async {
    final history = await _readAll();
    final json = history[wordId.toString()];
    if (json == null) return null;
    return WidgetHistoryEntry.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> saveEntry(WidgetHistoryEntry entry) async {
    final history = await _readAll();
    history[entry.wordId.toString()] = entry.toJson();
    await _prefs.setString(_key, jsonEncode(history));
  }

  Future<Map<String, dynamic>> _readAll() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
