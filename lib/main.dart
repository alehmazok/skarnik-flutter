import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_observer.dart';
import 'di.skarnik.dart';
import 'features/app/presentation/skarnik_app.dart';
import 'firebase_options.dart';
import 'logging.dart';

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
