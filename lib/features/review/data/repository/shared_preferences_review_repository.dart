import 'package:injectable/injectable.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repository/review_repository.dart';

@Injectable(as: ReviewRepository)
class SharedPreferencesReviewRepository implements ReviewRepository {
  static const _viewCountKey = 'review_translation_view_count';
  static const _alreadyRequestedKey = 'review_already_requested';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<bool> isReviewAlreadyRequested() =>
      _prefs.getBool(_alreadyRequestedKey).then((value) => value ?? false);

  @override
  Future<int> incrementAndGetTranslationViewCount() async {
    final next = (await _prefs.getInt(_viewCountKey) ?? 0) + 1;
    await _prefs.setInt(_viewCountKey, next);
    return next;
  }

  @override
  Future<void> markReviewRequested() => _prefs.setBool(_alreadyRequestedKey, true);

  @override
  Future<void> requestReview() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }
}
