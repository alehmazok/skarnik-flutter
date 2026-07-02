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
      final initialLink = await appLinks.getInitialLinkString();
      return Success(_mergedStream(appLinks, initialLink));
    } catch (e, st) {
      _logger.severe('Адбылася памылка атрымання стрыму app links:', e, st);
      return Failure(e);
    }
  }

  /// Cold start links are only available via [AppLinks.getInitialLinkString];
  /// [AppLinks.stringLinkStream] only emits links received while the app is
  /// already running. Prepend the initial link so both cases are handled
  /// through a single stream.
  Stream<String> _mergedStream(AppLinks appLinks, String? initialLink) async* {
    if (initialLink != null) {
      yield initialLink;
    }
    yield* appLinks.stringLinkStream;
  }
}
