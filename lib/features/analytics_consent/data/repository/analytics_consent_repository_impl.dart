import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/repository/analytics_consent_repository.dart';

@Injectable(as: AnalyticsConsentRepository)
class AnalyticsConsentRepositoryImpl implements AnalyticsConsentRepository {
  static const _answeredKey = 'analytics_consent_answered';
  static const _grantedKey = 'analytics_consent_granted';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<bool> hasAnswered() async => await _prefs.getBool(_answeredKey) ?? false;

  @override
  Future<bool> isGranted() async => await _prefs.getBool(_grantedKey) ?? false;

  @override
  Future<void> setConsent(bool granted) async {
    await _prefs.setBool(_answeredKey, true);
    await _prefs.setBool(_grantedKey, granted);
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(granted);
  }

  @override
  Future<void> applyStoredConsent() async {
    final granted = await isGranted();
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(granted);
  }
}
