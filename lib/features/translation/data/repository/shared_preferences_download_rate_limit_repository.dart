import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repository/download_rate_limit_repository.dart';

@Injectable(as: DownloadRateLimitRepository)
class SharedPreferencesDownloadRateLimitRepository implements DownloadRateLimitRepository {
  static const _recentAttemptsKey = 'download_recent_attempts_at_ms';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<List<DateTime>> getRecentAttempts() async {
    final stored = await _prefs.getStringList(_recentAttemptsKey) ?? const [];
    return stored.map((it) => DateTime.fromMillisecondsSinceEpoch(int.parse(it))).toList();
  }

  @override
  Future<void> saveRecentAttempts(List<DateTime> attempts) => _prefs.setStringList(
    _recentAttemptsKey,
    attempts.map((it) => '${it.millisecondsSinceEpoch}').toList(),
  );
}
