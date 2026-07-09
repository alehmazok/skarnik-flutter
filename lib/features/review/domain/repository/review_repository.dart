abstract interface class ReviewRepository {
  Future<bool> isReviewAlreadyRequested();

  Future<int> incrementAndGetTranslationViewCount();

  Future<void> markReviewRequested();

  Future<void> requestReview();
}
