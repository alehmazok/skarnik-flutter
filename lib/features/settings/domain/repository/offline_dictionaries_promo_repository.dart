abstract interface class OfflineDictionariesPromoRepository {
  Future<bool> isSeen();

  Future<void> markSeen();
}
