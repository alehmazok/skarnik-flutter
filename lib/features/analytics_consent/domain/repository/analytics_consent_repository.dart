abstract interface class AnalyticsConsentRepository {
  Future<bool> hasAnswered();

  Future<bool> isGranted();

  Future<void> setConsent(bool granted);

  Future<void> applyStoredConsent();
}
