import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/repository/analytics_app_repository.dart';

@dev
@Injectable(as: AnalyticsAppRepository)
class DevAnalyticsAppRepository implements AnalyticsAppRepository {
  final _logger = getLogger(DevAnalyticsAppRepository);

  @override
  Future<void> logAppStarted() async {
    _logger.info('Analytics event logged: app_started');
  }
}
