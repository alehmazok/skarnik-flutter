import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class GetAppLinkStreamUseCase {
  final _logger = getLogger(GetAppLinkStreamUseCase);

  GetAppLinkStreamUseCase();

  Future<UseCaseResult<Stream<String>>> call() async {
    try {
      final appLinks = AppLinks();
      return Success(appLinks.stringLinkStream);
    } catch (e, st) {
      _logger.severe('Адбылася памылка атрымання стрыму app links:', e, st);
      return Failure(e);
    }
  }
}
