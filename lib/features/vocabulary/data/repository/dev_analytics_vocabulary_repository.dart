import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/repository/analytics_vocabulary_repository.dart';

@dev
@Injectable(as: AnalyticsVocabularyRepository)
class DevAnalyticsVocabularyRepository implements AnalyticsVocabularyRepository {
  final _logger = getLogger(DevAnalyticsVocabularyRepository);

  @override
  Future<void> logWord(Word word) async {
    await Future.delayed(const Duration(seconds: 3));
    _logger.info('Analytics event logged: vocabulary');
  }
}
