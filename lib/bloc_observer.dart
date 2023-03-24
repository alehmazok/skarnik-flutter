import 'package:flutter_bloc/flutter_bloc.dart';

import 'logging.dart';

class DevelopmentBlocObserver extends BlocObserver {
  final _logger = getLogger(DevelopmentBlocObserver);

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.fine('🧱 ${bloc.runtimeType} event: ${event.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.fine('🧱 ${bloc.runtimeType} state was: ${change.currentState}, become: ${change.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.severe('🧱 ${bloc.runtimeType} error 💥💥💥:', error, stackTrace);
  }
}
