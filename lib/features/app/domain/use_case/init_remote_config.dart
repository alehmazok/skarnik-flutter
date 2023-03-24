import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/core/extensions.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class InitRemoteConfigUseCase extends NoArgsEitherUseCase<bool> {
  final _logger = getLogger(InitRemoteConfigUseCase);

  InitRemoteConfigUseCase();

  @override
  Future<Either<Object, bool>> call() async {
    try {
      final instance = FirebaseRemoteConfig.instance;
      instance.setConfigSettings(
        // Дэфолтныя вялiчынi.
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 12),
        ),
      );
      instance.setDefaults({
        AppConfig.httpCacheDurationInHours: 24,
      });

      // Не чакаць рэзультат.
      _fetchAndActivate(instance);

      return right(true);
    } catch (e, st) {
      _logger.severe('An error occurred:', e, st);

      return left(e);
    }
  }

  /// Нiчога страшэннага, калi тут здарыцца памылка. Будзем спадзявацца на наступны раз :)
  Future<bool> _fetchAndActivate(FirebaseRemoteConfig instance) async {
    try {
      final isSuccess = await instance.fetchAndActivate();
      _logger.fine('Новыя вялiчынi з Remote Config прымененыя?: ${isSuccess.takNie}.');
      return isSuccess;
    } catch (e, st) {
      _logger.warning('An error occurred while fetching new Remote Config values:', e, st);
      return false;
    }
  }
}
