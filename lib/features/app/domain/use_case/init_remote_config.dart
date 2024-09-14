import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/core/extensions.dart';
import 'package:skarnik_flutter/logging.dart';

@injectable
class InitRemoteConfigUseCase {
  final _logger = getLogger(InitRemoteConfigUseCase);

  InitRemoteConfigUseCase();

  Future<UseCaseResult<bool>> call() async {
    try {
      final instance = FirebaseRemoteConfig.instance;
      instance.setConfigSettings(
        // Дэфолтныя значэнні.
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 12),
        ),
      );
      instance.setDefaults({
        AppConfig.httpCacheDurationInHours: 24,
      });

      // Не чакаць вынік.
      _fetchAndActivate(instance);

      return const Success(true);
    } catch (e, st) {
      _logger.severe('An error occurred:', e, st);

      return Failure(e);
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
