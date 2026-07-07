import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/review_repository.dart';

@injectable
class CheckAndRequestReviewUseCase {
  final _logger = getLogger(CheckAndRequestReviewUseCase);

  final ReviewRepository _reviewRepository;

  CheckAndRequestReviewUseCase(this._reviewRepository);

  Future<UseCaseResult<bool>> call() async {
    try {
      if (await _reviewRepository.isReviewAlreadyRequested()) {
        return const Success(false);
      }
      final viewCount = await _reviewRepository.incrementAndGetTranslationViewCount();
      if (viewCount < AppConfig.reviewRequestViewThreshold) {
        return const Success(false);
      }
      // Пазначаем ДА выкліку requestReview(), каб запыт адбыўся не больш за адзін раз,
      // нават калі сам выклік кіне памылку ці праграма будзе закрыта пасярод яго выканання.
      await _reviewRepository.markReviewRequested();
      await _reviewRepository.requestReview();
      return const Success(true);
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе запытаць адзнаку прыкладання:', e, st);
      return const Success(false);
    }
  }
}
