abstract interface class ReviewRepository {
  Future<bool> isReviewAlreadyRequested();

  Future<int> incrementAndGetTranslationViewCount();

  Future<void> markReviewRequested();

  /// Returns true if the native review prompt was shown.
  Future<bool> requestReview();
}
