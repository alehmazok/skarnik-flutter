import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/repository/analytics_stress_repository.dart';

@dev
@Injectable(as: AnalyticsStressRepository)
class DevAnalyticsStressRepository implements AnalyticsStressRepository {
  final _logger = getLogger(DevAnalyticsStressRepository);

  @override
  Future<void> logStressClicked(String word) async {
    _logger.info('Analytics event logged: stress_clicked {"word": "$word"}');
  }
}
