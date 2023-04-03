import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class GetAppLinkStreamUseCase extends NoArgsEitherUseCase<Stream<String>> {
  final _logger = getLogger(GetAppLinkStreamUseCase);

  GetAppLinkStreamUseCase();

  @override
  Future<Either<Object, Stream<String>>> call() async {
    try {
      final appLinks = AppLinks();
      return right(appLinks.allStringLinkStream);
    } catch (e, st) {
      _logger.severe('Адбылася памылка атрымання стрыму app links:', e, st);
      return left(e);
    }
  }
}
