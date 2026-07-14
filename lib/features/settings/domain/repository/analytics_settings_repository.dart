import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

abstract interface class AnalyticsSettingsRepository {
  Future<void> logDictionaryDownloadClicked(Dictionary dictionary);
}
