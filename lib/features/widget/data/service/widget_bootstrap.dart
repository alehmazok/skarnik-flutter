import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart';
import 'package:skarnik_flutter/firebase_options.dart';
import 'package:skarnik_flutter/logging.dart';
import 'package:skarnik_flutter/objectbox.g.dart';
import 'package:skarnik_flutter/supabase_client.dart';

const _searchDirectoryName = 'objectbox_search';
const _historyDirectoryName = 'objectbox_history';
const _translationDirectoryName = 'objectbox_translation';

Completer<void>? _initialization;

/// Minimal DI bootstrap for the `workmanager` background isolate — trimmed to
/// what `RefreshWidgetDataUseCase`'s dependency graph needs. Runs in a
/// separate Dart isolate within the same OS process as the main app
/// (confirmed via spike), so ObjectBox stores must be attached to, not
/// re-opened, when the main app already has them open.
///
/// The periodic and initial one-off tasks can both invoke this concurrently
/// in the same isolate (confirmed on-device — see `_openOrAttach`'s retry
/// loop) — a plain `bool` guard would let both proceed past the check before
/// either finishes, so `getIt.registerSingleton` would throw on the second
/// call. Guard with a `Completer` instead so the second caller awaits the
/// first's in-flight bootstrap rather than racing it.
Future<void> ensureWidgetBootstrap() {
  final inProgress = _initialization;
  if (inProgress != null) return inProgress.future;

  final completer = Completer<void>();
  _initialization = completer;
  _bootstrap().then(
    completer.complete,
    onError: (Object e, StackTrace st) {
      _initialization = null;
      completer.completeError(e, st);
    },
  );
  return completer.future;
}

Future<void> _bootstrap() async {
  // Runs in its own Dart isolate group (separate FlutterEngine) with its own
  // static state, so logging/DI must be set up here too, not inherited from
  // the main isolate.
  Logging.setupLogger(level: kDebugMode ? Level.ALL : Level.SEVERE);
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies(kDebugMode ? 'dev' : 'prod');
  // GetTranslationUseCase's API/website tiers read the Dio cache duration
  // from Firebase Remote Config — without an initialized app they throw
  // `[core/no-app]` on every attempt (confirmed on-device).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _registerObjectboxStoreHolder();
  await SupabaseConfig.initialize();
}

Future<void> _registerObjectboxStoreHolder() async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final searchStore = await _openOrAttach(join(documentsDir.path, _searchDirectoryName));
  final historyStore = await _openOrAttach(join(documentsDir.path, _historyDirectoryName));
  final translationStore = await _openOrAttach(join(documentsDir.path, _translationDirectoryName));
  getIt.registerSingleton(
    ObjectboxStoreHolder(
      searchStore: searchStore,
      historyStore: historyStore,
      translationStore: translationStore,
    ),
  );
}

final _logger = getLogger(ObjectboxStoreHolder);

const _maxOpenAttempts = 5;
const _retryDelay = Duration(milliseconds: 300);

/// The periodic and initial one-off `workmanager` tasks can both become
/// eligible to run around app startup, racing each other (and the main
/// isolate's own first-launch asset-seeding copy) to open the same store —
/// confirmed on-device. Retry-with-backoff rather than a native fallback,
/// per the widget plan's resolved risk mitigation: an occasional delayed
/// refresh is fine, losing the Dart-side cascade reuse is not.
Future<Store> _openOrAttach(String directory) async {
  Object? lastError;
  for (var attempt = 1; attempt <= _maxOpenAttempts; attempt++) {
    try {
      final store = Store.attach(getObjectBoxModel(), directory);
      _logger.fine('Attached to store at $directory (attempt $attempt).');
      return store;
    } catch (e) {
      lastError = e;
    }
    try {
      final store = await openStore(directory: directory);
      _logger.fine('Opened fresh store at $directory (attempt $attempt).');
      return store;
    } catch (e) {
      lastError = e;
    }
    await Future<void>.delayed(_retryDelay);
  }
  _logger.severe(
    'Не атрымалася адкрыць/далучыцца да сховішча $directory пасля $_maxOpenAttempts спроб.',
    lastError,
  );
  throw StateError('Не атрымалася адкрыць ObjectBox сховішча: $directory');
}
