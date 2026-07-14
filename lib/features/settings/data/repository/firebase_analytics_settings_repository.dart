import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../../domain/repository/analytics_settings_repository.dart';

@prod
@Injectable(as: AnalyticsSettingsRepository)
class FirebaseAnalyticsSettingsRepository implements AnalyticsSettingsRepository {
  @override
  Future<void> logDictionaryDownloadClicked(Dictionary dictionary) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'offline_dictionary_download_click',
      parameters: {
        'dict_name': dictionary.name,
        'dict_path': dictionary.path,
      },
    );
  }
}
