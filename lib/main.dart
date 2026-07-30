import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';

import 'bloc_observer.dart';
import 'di.skarnik.dart';
import 'features/analytics_consent/domain/use_case/init_analytics_consent.dart';
import 'features/app/presentation/skarnik_app.dart';
import 'features/widget/presentation/widget_callback_dispatcher.dart' as word_of_day_widget;
import 'firebase_options.dart';
import 'logging.dart';
import 'supabase_client.dart';

void main() async {
  Logging.setupLogger(
    level: kDebugMode ? Level.ALL : Level.SEVERE,
    recordError: !kDebugMode,
  );

  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies(kDebugMode ? 'dev' : 'prod');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Must run before any Analytics event can fire (e.g. SkarnikAppBloc's
  // app-open log), so the persisted/default-off consent flag is already
  // applied to the SDK by the time the app starts.
  await getIt<InitAnalyticsConsentUseCase>()();

  await SupabaseConfig.initialize();

  if (Platform.isAndroid) {
    await Workmanager().initialize(
      word_of_day_widget.widgetCallbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    await Workmanager().registerPeriodicTask(
      'word-of-day-refresh',
      word_of_day_widget.wordOfDayTaskName,
      frequency: const Duration(hours: 1),
    );
    // Populate a freshly-added widget immediately instead of leaving it blank
    // for up to an hour until the first periodic tick.
    await Workmanager().registerOneOffTask(
      'word-of-day-refresh-initial',
      word_of_day_widget.wordOfDayTaskName,
    );
  }

  if (kDebugMode) {
    Bloc.observer = DevelopmentBlocObserver();
  } else {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics.
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

      return true;
    };
  }

  runApp(const SkarnikApp());
}
