import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';

import 'di.skarnik.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  ignoreUnregisteredTypes: [
    ObjectboxStoreHolder,
  ],
)
void configureDependencies(String environment) => getIt.init(environment: environment);
