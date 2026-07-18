import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/features/settings/domain/repository/offline_dictionaries_promo_repository.dart';

// App-scoped singleton: the badge is read from the History app bar and
// cleared from the Settings page, so both need to see the same instance.
@lazySingleton
class OfflineDictionariesPromoCubit extends Cubit<bool> {
  OfflineDictionariesPromoCubit(this._repository) : super(false) {
    scheduleMicrotask(_load);
  }

  final OfflineDictionariesPromoRepository _repository;

  Future<void> _load() async {
    final seen = await _repository.isSeen();
    if (isClosed) return;
    emit(!seen);
  }

  Future<void> markSeen() async {
    if (isClosed || !state) return;
    emit(false);
    await _repository.markSeen();
  }
}
