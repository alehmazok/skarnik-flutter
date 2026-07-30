import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/repository/analytics_consent_repository.dart';
import 'package:skarnik_flutter/features/analytics_consent/domain/use_case/set_analytics_consent.dart';

typedef AnalyticsConsentState = ({bool hasAnswered, bool granted});

// App-scoped singleton: the first-launch dialog (HomeShell) and the Settings
// toggle both read/write the same consent decision, so they need to share
// state instead of re-loading it independently.
@lazySingleton
class AnalyticsConsentCubit extends Cubit<AnalyticsConsentState?> {
  AnalyticsConsentCubit(this._repository, this._setAnalyticsConsentUseCase) : super(null) {
    scheduleMicrotask(_load);
  }

  final AnalyticsConsentRepository _repository;
  final SetAnalyticsConsentUseCase _setAnalyticsConsentUseCase;

  Future<void> _load() async {
    final hasAnswered = await _repository.hasAnswered();
    final granted = await _repository.isGranted();
    if (isClosed) return;
    emit((hasAnswered: hasAnswered, granted: granted));
  }

  Future<void> setConsent(bool granted) async {
    await _setAnalyticsConsentUseCase(granted);
    if (isClosed) return;
    emit((hasAnswered: true, granted: granted));
  }
}
