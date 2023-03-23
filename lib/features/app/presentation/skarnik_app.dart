import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';

import '../domain/use_case/init_database.dart';
import 'skarnk_router.dart';
import 'skarnik_app_cubit.dart';

class SkarnikApp extends StatelessWidget {
  const SkarnikApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          primaryContainer: Colors.red,
          onPrimaryContainer: Colors.white,
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      initial: AdaptiveThemeMode.system,
      builder: (lightTheme, darkTheme) => BlocProvider(
        create: (context) => SkarnikAppCubit(
          initDatabaseUseCase: getIt<InitDatabaseUseCase>(),
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
