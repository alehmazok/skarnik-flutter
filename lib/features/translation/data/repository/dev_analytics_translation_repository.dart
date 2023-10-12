import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
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
  Future<void> logShare(String itemId) async {
    _logger.info('Analytics event logged: share {"item_id": "$itemId"}');
  }

  @override
  Future<void> logAddToFavorites(Word word) async {
    _logger.info('Analytics event logged: add_to_favorites');
  }
}
