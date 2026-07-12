abstract interface class DownloadRateLimitRepository {
  Future<List<DateTime>> getRecentAttempts();

  Future<void> saveRecentAttempts(List<DateTime> attempts);
}
