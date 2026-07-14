import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/repository/analytics_settings_repository.dart';

@dev
@Injectable(as: AnalyticsSettingsRepository)
class DevAnalyticsSettingsRepository implements AnalyticsSettingsRepository {
  final _logger = getLogger(DevAnalyticsSettingsRepository);

  @override
  Future<void> logDictionaryDownloadClicked(Dictionary dictionary) async {
    _logger.info(
      'Analytics event logged: offline_dictionary_download_click {"dict_path": "${dictionary.path}"}',
    );
  }
}
