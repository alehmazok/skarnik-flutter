import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/download_progress.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/check_download_rate_limit.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/clear_downloaded_dictionary.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/count_downloaded_words.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/download_dictionary.dart';

sealed class DictionaryOfflineStatus extends Equatable {
  const DictionaryOfflineStatus();

  @override
  List<Object?> get props => [];
}

class DictionaryNotDownloaded extends DictionaryOfflineStatus {
  const DictionaryNotDownloaded();
}

class DictionaryDownloading extends DictionaryOfflineStatus {
  final DownloadProgress progress;

  const DictionaryDownloading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DictionaryDownloaded extends DictionaryOfflineStatus {
  final int wordCount;

  const DictionaryDownloaded(this.wordCount);

  @override
  List<Object?> get props => [wordCount];
}

class DictionaryDownloadFailed extends DictionaryOfflineStatus {
  final Object error;

  const DictionaryDownloadFailed(this.error);

  @override
  List<Object?> get props => [error];
}

// App-scoped singleton, not page-scoped: a download must outlive the
// Settings page being popped, otherwise navigating away mid-download
// silently truncates it (ObjectBox already has whatever was written so
// far, but the UI would show it as a complete, checkmarked download).
@lazySingleton
class OfflineDictionariesCubit extends Cubit<Map<Dictionary, DictionaryOfflineStatus>> {
  OfflineDictionariesCubit({
    required this.downloadDictionaryUseCase,
    required this.clearDownloadedDictionaryUseCase,
    required this.countDownloadedWordsUseCase,
    required this.checkDownloadRateLimitUseCase,
  }) : super({
         for (final dictionary in Dictionary.values) dictionary: const DictionaryNotDownloaded(),
       }) {
    _loadDownloadedCounts();
  }

  final DownloadDictionaryUseCase downloadDictionaryUseCase;
  final ClearDownloadedDictionaryUseCase clearDownloadedDictionaryUseCase;
  final CountDownloadedWordsUseCase countDownloadedWordsUseCase;
  final CheckDownloadRateLimitUseCase checkDownloadRateLimitUseCase;

  Future<void> _loadDownloadedCounts() async {
    for (final dictionary in Dictionary.values) {
      final count = await countDownloadedWordsUseCase(dictionary);
      if (isClosed) return;
      if (count > 0) {
        emit({...state, dictionary: DictionaryDownloaded(count)});
      }
    }
  }

  // isClosed guards are defensive only — this cubit is an app-scoped
  // singleton and normally never closes, but emit() after close() throws,
  // so guard anyway rather than rely on that assumption holding forever.
  //
  // Returns false if the attempt was rejected by the rate limit (caller
  // shows a SnackBar), true once the download has actually started —
  // the download itself keeps running in the background and reports
  // progress through emitted state, same as before.
  Future<bool> download(Dictionary dictionary) async {
    final allowed = await checkDownloadRateLimitUseCase();
    if (isClosed || !allowed) return false;

    unawaited(_runDownload(dictionary));
    return true;
  }

  Future<void> _runDownload(Dictionary dictionary) async {
    try {
      await for (final progress in downloadDictionaryUseCase(dictionary)) {
        if (isClosed) return;
        emit({...state, dictionary: DictionaryDownloading(progress)});
      }
      if (isClosed) return;
      final count = await countDownloadedWordsUseCase(dictionary);
      if (isClosed) return;
      emit({...state, dictionary: DictionaryDownloaded(count)});
    } catch (e) {
      if (isClosed) return;
      emit({...state, dictionary: DictionaryDownloadFailed(e)});
    }
  }

  Future<void> delete(Dictionary dictionary) async {
    final result = await clearDownloadedDictionaryUseCase(dictionary);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit({...state, dictionary: const DictionaryNotDownloaded()});
      case Failure(error: final error):
        emit({...state, dictionary: DictionaryDownloadFailed(error)});
    }
  }
}
