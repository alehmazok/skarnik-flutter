import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repository/analytics_app_repository.dart';

@prod
@Injectable(as: AnalyticsAppRepository)
class FirebaseAnalyticsAppRepository implements AnalyticsAppRepository {
  @override
  Future<void> logAppStarted() async {
    final analytics = FirebaseAnalytics.instance;
    await analytics.logAppOpen();
  }
}
