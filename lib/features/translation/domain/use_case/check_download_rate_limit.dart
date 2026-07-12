import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';

import '../repository/download_rate_limit_repository.dart';

@injectable
class CheckDownloadRateLimitUseCase {
  final DownloadRateLimitRepository _repository;

  CheckDownloadRateLimitUseCase(this._repository);

  /// Returns true and records this attempt if the caller may start a
  /// download now. Returns false (without recording) if
  /// [AppConfig.downloadMaxAttemptsPerWindow] attempts already happened
  /// within [AppConfig.downloadRateLimitWindow].
  Future<bool> call() async {
    final now = DateTime.now();
    final windowStart = now.subtract(AppConfig.downloadRateLimitWindow);
    final recentAttempts = (await _repository.getRecentAttempts())
        .where((attempt) => attempt.isAfter(windowStart))
        .toList();

    if (recentAttempts.length >= AppConfig.downloadMaxAttemptsPerWindow) {
      // Persist the pruned list even when blocked, so stale entries don't
      // linger forever in storage.
      await _repository.saveRecentAttempts(recentAttempts);
      return false;
    }

    recentAttempts.add(now);
    await _repository.saveRecentAttempts(recentAttempts);
    return true;
  }
}
