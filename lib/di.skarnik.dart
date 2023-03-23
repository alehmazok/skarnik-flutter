import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart';

import 'di.skarnik.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  ignoreUnregisteredTypes: [
    ObjectboxService,
  ],
)
void configureDependencies(String environment) => getIt.init(environment: environment);
