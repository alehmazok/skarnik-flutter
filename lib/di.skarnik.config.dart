// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:skarnik_flutter/features/app/data/repository/objectbox_database_repository.dart'
    as _i4;
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart'
    as _i9;
import 'package:skarnik_flutter/features/app/domain/repository/database_repository.dart'
    as _i3;
import 'package:skarnik_flutter/features/app/domain/use_case/get_app_link_stream.dart'
    as _i5;
import 'package:skarnik_flutter/features/app/domain/use_case/handle_app_link.dart'
    as _i6;
import 'package:skarnik_flutter/features/app/domain/use_case/init_database.dart'
    as _i12;
import 'package:skarnik_flutter/features/app/domain/use_case/init_remote_config.dart'
    as _i13;
import 'package:skarnik_flutter/features/app/domain/use_case/log_analytics_app_started.dart'
    as _i15;
import 'package:skarnik_flutter/features/history/data/repository/objectbox_history_repository.dart'
    as _i11;
import 'package:skarnik_flutter/features/history/domain/repository/history_repository.dart'
    as _i10;
import 'package:skarnik_flutter/features/history/domain/use_case/load_history.dart'
    as _i14;
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart'
    as _i20;
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart'
    as _i19;
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart'
    as _i21;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_history_repository.dart'
    as _i8;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_word_repository.dart'
    as _i25;
import 'package:skarnik_flutter/features/translation/data/repository/skarnik_translation_repository.dart'
    as _i23;
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart'
    as _i7;
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart'
    as _i22;
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart'
    as _i24;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart'
    as _i26;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_word.dart'
    as _i27;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_share.dart'
    as _i16;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_translation.dart'
    as _i17;
import 'package:skarnik_flutter/features/translation/domain/use_case/save_to_history.dart'
    as _i18;

extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.DatabaseRepository>(() => _i4.ObjectboxDatabaseRepository());
    gh.factory<_i5.GetAppLinkStreamUseCase>(
        () => _i5.GetAppLinkStreamUseCase());
    gh.factory<_i6.HandleAppLinkUseCase>(() => _i6.HandleAppLinkUseCase());
    gh.factory<_i7.HistoryRepository>(
        () => _i8.ObjectboxHistoryRepository(gh<_i9.ObjectboxService>()));
    gh.factory<_i10.HistoryRepository>(
        () => _i11.ObjectboxHistoryRepository(gh<_i9.ObjectboxService>()));
    gh.factory<_i12.InitDatabaseUseCase>(
        () => _i12.InitDatabaseUseCase(gh<_i3.DatabaseRepository>()));
    gh.factory<_i13.InitRemoteConfigUseCase>(
        () => _i13.InitRemoteConfigUseCase());
    gh.factory<_i14.LoadHistoryUseCase>(
        () => _i14.LoadHistoryUseCase(gh<_i10.HistoryRepository>()));
    gh.factory<_i15.LogAnalyticsAppOpenUseCase>(
        () => _i15.LogAnalyticsAppOpenUseCase());
    gh.factory<_i16.LogAnalyticsShareUseCase>(
        () => _i16.LogAnalyticsShareUseCase());
    gh.factory<_i17.LogAnalyticsTranslationUseCase>(
        () => _i17.LogAnalyticsTranslationUseCase());
    gh.factory<_i18.SaveToHistoryUseCase>(
        () => _i18.SaveToHistoryUseCase(gh<_i7.HistoryRepository>()));
    gh.factory<_i19.SearchRepository>(
        () => _i20.ObjectboxSearchRepository(gh<_i9.ObjectboxService>()));
    gh.factory<_i21.SearchUseCase>(
        () => _i21.SearchUseCase(gh<_i19.SearchRepository>()));
    gh.factory<_i22.TranslationRepository>(
        () => _i23.SkarnikTranslationRepository());
    gh.factory<_i24.WordRepository>(
        () => _i25.ObjectboxWordRepository(gh<_i9.ObjectboxService>()));
    gh.factory<_i26.GetTranslationUseCase>(
        () => _i26.GetTranslationUseCase(gh<_i22.TranslationRepository>()));
    gh.factory<_i27.GetWordUseCase>(
        () => _i27.GetWordUseCase(gh<_i24.WordRepository>()));
    return this;
  }
}
