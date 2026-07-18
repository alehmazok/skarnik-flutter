import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../repository/review_repository.dart';

enum ReviewOutcome {
  /// Threshold not reached yet, or review already requested before.
  notEligible,

  /// Native review prompt was shown.
  shown,

  /// Eligible, but the native review prompt is unavailable on this device
  /// (e.g. no Google Play Services on Huawei devices).
  unavailable,
}

@injectable
class CheckAndRequestReviewUseCase {
  final _logger = getLogger(CheckAndRequestReviewUseCase);

  final ReviewRepository _reviewRepository;

  CheckAndRequestReviewUseCase(this._reviewRepository);

  Future<UseCaseResult<ReviewOutcome>> call() async {
    try {
      if (await _reviewRepository.isReviewAlreadyRequested()) {
        return const Success(ReviewOutcome.notEligible);
      }
      final viewCount = await _reviewRepository.incrementAndGetTranslationViewCount();
      if (viewCount < AppConfig.reviewRequestViewThreshold) {
        return const Success(ReviewOutcome.notEligible);
      }
      // Пазначаем ДА выкліку requestReview(), каб запыт адбыўся не больш за адзін раз,
      // нават калі сам выклік кіне памылку ці праграма будзе закрыта пасярод яго выканання.
      await _reviewRepository.markReviewRequested();
      final shown = await _reviewRepository.requestReview();
      return Success(shown ? ReviewOutcome.shown : ReviewOutcome.unavailable);
    } catch (e, st) {
      _logger.warning('Адбылася памылка пры спробе запытаць адзнаку прыкладання:', e, st);
      return const Success(ReviewOutcome.notEligible);
    }
  }
}
