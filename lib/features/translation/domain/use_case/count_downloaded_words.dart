import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../repository/local_translation_repository.dart';

@injectable
class CountDownloadedWordsUseCase {
  final LocalTranslationRepository _localTranslationRepository;

  CountDownloadedWordsUseCase(this._localTranslationRepository);

  Future<int> call(Dictionary dictionary) => _localTranslationRepository.count(dictionary.langId);
}
