import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/entity/translation.dart';
import '../../domain/repository/analytics_translation_repository.dart';

@dev
@Injectable(as: AnalyticsTranslationRepository)
class DevAnalyticsTranslationRepository implements AnalyticsTranslationRepository {
  final _logger = getLogger(DevAnalyticsTranslationRepository);

  @override
  Future<void> logTranslation(Translation translation) async {
    _logger.info('Analytics event logged: translation');
  }

  @override
  Future<void> logShare(Translation translation) async {
    _logger.info('Analytics event logged: share');
  }
}
