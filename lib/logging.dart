// ignore_for_file: avoid_print
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logging/logging.dart';

export 'package:logging/logging.dart';

abstract class Logging {
  static setupLogger({Level level = Level.INFO, bool recordError = false}) {
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}');
      if (record.error != null) {
        print('${record.level.name}: ${record.loggerName}: ${record.time}: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('${record.level.name}: ${record.loggerName}: ${record.time}: ${record.stackTrace}');
      }
      if (record.level == Level.SEVERE && recordError) {
        FirebaseCrashlytics.instance.recordError(record.error, record.stackTrace, reason: record.message);
      }
    });
  }
}

// Ігнаруецца для больш зручнага выкліку.
// ignore: prefer-static-class
Logger getLogger(Type type) => Logger(type.toString());
