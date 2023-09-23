import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';

import '../domain/use_case/get_app_link_stream.dart';
import '../domain/use_case/handle_app_link.dart';
import '../domain/use_case/init_database.dart';
import '../domain/use_case/init_remote_config.dart';
import '../domain/use_case/log_analytics_app_started.dart';
import 'skarnik_app_bloc.dart';
import 'skarnk_router.dart';

class SkarnikApp extends StatelessWidget {
  const SkarnikApp({Key? key}) : super(key: key);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.grey,
      primaryContainer: Colors.red,
      onPrimaryContainer: Colors.white,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );

  static final darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: lightTheme,
      dark: darkTheme,
      initial: AdaptiveThemeMode.system,
      builder: (lightTheme, darkTheme) => BlocProvider(
        create: (context) => SkarnikAppBloc(
          initDatabaseUseCase: getIt<InitDatabaseUseCase>(),
          initRemoteConfigUseCase: getIt<InitRemoteConfigUseCase>(),
          getAppLinkStreamUseCase: getIt<GetAppLinkStreamUseCase>(),
          handleAppLinkUseCase: getIt<HandleAppLinkUseCase>(),
          logAnalyticsAppOpenUseCase: getIt<LogAnalyticsAppOpenUseCase>(),
        ),
        child: MaterialApp.router(
          routerConfig: SkarnikRouter.goRouter,
          theme: lightTheme,
          darkTheme: darkTheme,
        ),
      ),
    );
  }
}
