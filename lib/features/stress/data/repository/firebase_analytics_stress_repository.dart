import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repository/analytics_stress_repository.dart';

@prod
@Injectable(as: AnalyticsStressRepository)
class FirebaseAnalyticsStressRepository implements AnalyticsStressRepository {
  @override
  Future<void> logStressClicked(String word) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'stress_clicked',
      parameters: {'word': word},
    );
  }
}
