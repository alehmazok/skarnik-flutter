import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';

abstract class AnalyticsTranslationRepository {
  const AnalyticsTranslationRepository._();

  Future<void> logTranslation(Translation translation);

  Future<void> logShare(Translation translation);
}
