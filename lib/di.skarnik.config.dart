// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:skarnik_flutter/features/app/data/repository/objectbox_database_repository.dart'
    as _i4;
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart'
    as _i11;
import 'package:skarnik_flutter/features/app/domain/repository/database_repository.dart'
    as _i3;
import 'package:skarnik_flutter/features/app/domain/use_case/get_app_link_stream.dart'
    as _i7;
import 'package:skarnik_flutter/features/app/domain/use_case/handle_app_link.dart'
    as _i8;
import 'package:skarnik_flutter/features/app/domain/use_case/init_database.dart'
    as _i14;
import 'package:skarnik_flutter/features/app/domain/use_case/init_remote_config.dart'
    as _i15;
import 'package:skarnik_flutter/features/app/domain/use_case/log_analytics_app_started.dart'
    as _i17;
import 'package:skarnik_flutter/features/history/data/repository/objectbox_history_repository.dart'
    as _i13;
import 'package:skarnik_flutter/features/history/domain/repository/history_repository.dart'
    as _i12;
import 'package:skarnik_flutter/features/history/domain/use_case/load_history.dart'
    as _i16;
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart'
    as _i22;
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart'
    as _i21;
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart'
    as _i23;
import 'package:skarnik_flutter/features/translation/data/http/skarnik_dio.dart'
    as _i6;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_history_repository.dart'
    as _i10;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_word_repository.dart'
    as _i27;
import 'package:skarnik_flutter/features/translation/data/repository/skarnik_translation_repository.dart'
    as _i25;
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart'
    as _i9;
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart'
    as _i24;
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart'
    as _i26;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart'
    as _i28;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_word.dart'
    as _i29;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_share.dart'
    as _i18;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_translation.dart'
    as _i19;
import 'package:skarnik_flutter/features/translation/domain/use_case/save_to_history.dart'
    as _i20;

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
    gh.singleton<_i5.Dio>(_i6.SkarnikDio());
    gh.factory<_i7.GetAppLinkStreamUseCase>(
        () => _i7.GetAppLinkStreamUseCase());
    gh.factory<_i8.HandleAppLinkUseCase>(() => _i8.HandleAppLinkUseCase());
    gh.factory<_i9.HistoryRepository>(
        () => _i10.ObjectboxHistoryRepository(gh<_i11.ObjectboxService>()));
    gh.factory<_i12.HistoryRepository>(
        () => _i13.ObjectboxHistoryRepository(gh<_i11.ObjectboxService>()));
    gh.factory<_i14.InitDatabaseUseCase>(
        () => _i14.InitDatabaseUseCase(gh<_i3.DatabaseRepository>()));
    gh.factory<_i15.InitRemoteConfigUseCase>(
        () => _i15.InitRemoteConfigUseCase());
    gh.factory<_i16.LoadHistoryUseCase>(
        () => _i16.LoadHistoryUseCase(gh<_i12.HistoryRepository>()));
    gh.factory<_i17.LogAnalyticsAppOpenUseCase>(
        () => _i17.LogAnalyticsAppOpenUseCase());
    gh.factory<_i18.LogAnalyticsShareUseCase>(
        () => _i18.LogAnalyticsShareUseCase());
    gh.factory<_i19.LogAnalyticsTranslationUseCase>(
        () => _i19.LogAnalyticsTranslationUseCase());
    gh.factory<_i20.SaveToHistoryUseCase>(
        () => _i20.SaveToHistoryUseCase(gh<_i9.HistoryRepository>()));
    gh.factory<_i21.SearchRepository>(
        () => _i22.ObjectboxSearchRepository(gh<_i11.ObjectboxService>()));
    gh.factory<_i23.SearchUseCase>(
        () => _i23.SearchUseCase(gh<_i21.SearchRepository>()));
    gh.factory<_i24.TranslationRepository>(
        () => _i25.SkarnikTranslationRepository(gh<_i5.Dio>()));
    gh.factory<_i26.WordRepository>(
        () => _i27.ObjectboxWordRepository(gh<_i11.ObjectboxService>()));
    gh.factory<_i28.GetTranslationUseCase>(
        () => _i28.GetTranslationUseCase(gh<_i24.TranslationRepository>()));
    gh.factory<_i29.GetWordUseCase>(
        () => _i29.GetWordUseCase(gh<_i26.WordRepository>()));
    return this;
  }
}
