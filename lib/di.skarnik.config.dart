// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:skarnik_flutter/features/app/data/repository/dev_analytics_app_repository.dart'
    as _i4;
import 'package:skarnik_flutter/features/app/data/repository/firebase_analytics_app_repository.dart'
    as _i5;
import 'package:skarnik_flutter/features/app/data/repository/objectbox_database_repository.dart'
    as _i10;
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart'
    as _i17;
import 'package:skarnik_flutter/features/app/domain/repository/analytics_app_repository.dart'
    as _i3;
import 'package:skarnik_flutter/features/app/domain/repository/database_repository.dart'
    as _i9;
import 'package:skarnik_flutter/features/app/domain/use_case/get_app_link_stream.dart'
    as _i18;
import 'package:skarnik_flutter/features/app/domain/use_case/handle_app_link.dart'
    as _i19;
import 'package:skarnik_flutter/features/app/domain/use_case/init_database.dart'
    as _i22;
import 'package:skarnik_flutter/features/app/domain/use_case/init_remote_config.dart'
    as _i23;
import 'package:skarnik_flutter/features/app/domain/use_case/log_analytics_app_started.dart'
    as _i27;
import 'package:skarnik_flutter/features/favorites/domain/use_case/load_favorites.dart'
    as _i24;
import 'package:skarnik_flutter/features/home/domain/use_case/load_history.dart'
    as _i25;
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart'
    as _i34;
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart'
    as _i33;
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart'
    as _i35;
import 'package:skarnik_flutter/features/settings/data/repository/objectbox_settings_history_repository.dart'
    as _i37;
import 'package:skarnik_flutter/features/settings/domain/repository/settings_history_repository.dart'
    as _i36;
import 'package:skarnik_flutter/features/settings/domain/use_case/clear_history.dart'
    as _i44;
import 'package:skarnik_flutter/features/translation/data/http/skarnik_dio.dart'
    as _i12;
import 'package:skarnik_flutter/features/translation/data/repository/api_translation_repository.dart'
    as _i30;
import 'package:skarnik_flutter/features/translation/data/repository/dev_analytics_translation_repository.dart'
    as _i7;
import 'package:skarnik_flutter/features/translation/data/repository/firebase_analytics_translation_repository.dart'
    as _i8;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_favorites_repository.dart'
    as _i16;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_history_repository.dart'
    as _i21;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_word_repository.dart'
    as _i41;
import 'package:skarnik_flutter/features/translation/data/repository/skarnik_translation_repository.dart'
    as _i14;
import 'package:skarnik_flutter/features/translation/domain/repository/analytics_translation_repository.dart'
    as _i6;
import 'package:skarnik_flutter/features/translation/domain/repository/favorites_repository.dart'
    as _i15;
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart'
    as _i20;
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart'
    as _i13;
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart'
    as _i40;
import 'package:skarnik_flutter/features/translation/domain/use_case/add_to_favorites.dart'
    as _i42;
import 'package:skarnik_flutter/features/translation/domain/use_case/check_in_favorites.dart'
    as _i43;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart'
    as _i45;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_word.dart'
    as _i46;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_add_to_favorites.dart'
    as _i26;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_share.dart'
    as _i28;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_translation.dart'
    as _i29;
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart'
    as _i31;
import 'package:skarnik_flutter/features/translation/domain/use_case/save_to_history.dart'
    as _i32;
import 'package:skarnik_flutter/features/vocabulary/data/repository/vocabulary_repository.dart'
    as _i39;
import 'package:skarnik_flutter/features/vocabulary/domain/repository/vocabulary_repository.dart'
    as _i38;
import 'package:skarnik_flutter/features/vocabulary/domain/use_case/load_vocabulary.dart'
    as _i47;

const String _prod = 'prod';
const String _dev = 'dev';

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
    gh.factory<_i3.AnalyticsAppRepository>(
      () => _i4.DevAnalyticsAppRepository(),
      registerFor: {_dev},
    );
    gh.factory<_i3.AnalyticsAppRepository>(
      () => _i5.FirebaseAnalyticsAppRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i6.AnalyticsTranslationRepository>(
      () => _i7.DevAnalyticsTranslationRepository(),
      registerFor: {_dev},
    );
    gh.factory<_i6.AnalyticsTranslationRepository>(
      () => _i8.FirebaseAnalyticsTranslationRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i9.DatabaseRepository>(
        () => _i10.ObjectboxDatabaseRepository());
    gh.singleton<_i11.Dio>(_i12.SkarnikDio());
    gh.factory<_i13.FallbackTranslationRepository>(
        () => _i14.SkarnikTranslationRepository(gh<_i11.Dio>()));
    gh.factory<_i15.FavoritesRepository>(() =>
        _i16.ObjectboxFavoritesRepository(gh<_i17.ObjectboxStoreHolder>()));
    gh.factory<_i18.GetAppLinkStreamUseCase>(
        () => _i18.GetAppLinkStreamUseCase());
    gh.factory<_i19.HandleAppLinkUseCase>(() => _i19.HandleAppLinkUseCase());
    gh.factory<_i20.HistoryRepository>(
        () => _i21.ObjectboxHistoryRepository(gh<_i17.ObjectboxStoreHolder>()));
    gh.factory<_i22.InitDatabaseUseCase>(
        () => _i22.InitDatabaseUseCase(gh<_i9.DatabaseRepository>()));
    gh.factory<_i23.InitRemoteConfigUseCase>(
        () => _i23.InitRemoteConfigUseCase());
    gh.factory<_i24.LoadFavoritesUseCase>(
        () => _i24.LoadFavoritesUseCase(gh<_i15.FavoritesRepository>()));
    gh.factory<_i25.LoadHistoryUseCase>(
        () => _i25.LoadHistoryUseCase(gh<_i20.HistoryRepository>()));
    gh.factory<_i26.LogAnalyticsAddToFavoritesUseCase>(() =>
        _i26.LogAnalyticsAddToFavoritesUseCase(
            gh<_i6.AnalyticsTranslationRepository>()));
    gh.factory<_i27.LogAnalyticsAppOpenUseCase>(() =>
        _i27.LogAnalyticsAppOpenUseCase(gh<_i3.AnalyticsAppRepository>()));
    gh.factory<_i28.LogAnalyticsShareUseCase>(() =>
        _i28.LogAnalyticsShareUseCase(
            gh<_i6.AnalyticsTranslationRepository>()));
    gh.factory<_i29.LogAnalyticsTranslationUseCase>(() =>
        _i29.LogAnalyticsTranslationUseCase(
            gh<_i6.AnalyticsTranslationRepository>()));
    gh.factory<_i13.PrimaryTranslationRepository>(
        () => _i30.ApiTranslationRepository(gh<_i11.Dio>()));
    gh.factory<_i31.RemoveFromFavoritesUseCase>(
        () => _i31.RemoveFromFavoritesUseCase(gh<_i15.FavoritesRepository>()));
    gh.factory<_i32.SaveToHistoryUseCase>(
        () => _i32.SaveToHistoryUseCase(gh<_i20.HistoryRepository>()));
    gh.factory<_i33.SearchRepository>(
        () => _i34.ObjectboxSearchRepository(gh<_i17.ObjectboxStoreHolder>()));
    gh.factory<_i35.SearchUseCase>(
        () => _i35.SearchUseCase(gh<_i33.SearchRepository>()));
    gh.factory<_i36.SettingsHistoryRepository>(() =>
        _i37.ObjectboxSettingsHistoryRepository(
            gh<_i17.ObjectboxStoreHolder>()));
    gh.factory<_i38.VocabularyRepository>(() =>
        _i39.ObjectboxVocabularyRepository(gh<_i17.ObjectboxStoreHolder>()));
    gh.factory<_i40.WordRepository>(
        () => _i41.ObjectboxWordRepository(gh<_i17.ObjectboxStoreHolder>()));
    gh.factory<_i42.AddToFavoritesUseCase>(
        () => _i42.AddToFavoritesUseCase(gh<_i15.FavoritesRepository>()));
    gh.factory<_i43.CheckInFavoritesUseCase>(
        () => _i43.CheckInFavoritesUseCase(gh<_i15.FavoritesRepository>()));
    gh.factory<_i44.ClearHistoryUseCase>(
        () => _i44.ClearHistoryUseCase(gh<_i36.SettingsHistoryRepository>()));
    gh.factory<_i45.GetTranslationUseCase>(() => _i45.GetTranslationUseCase(
          gh<_i13.PrimaryTranslationRepository>(),
          gh<_i13.FallbackTranslationRepository>(),
        ));
    gh.factory<_i46.GetWordUseCase>(
        () => _i46.GetWordUseCase(gh<_i40.WordRepository>()));
    gh.factory<_i47.LoadVocabularyUseCase>(
        () => _i47.LoadVocabularyUseCase(gh<_i38.VocabularyRepository>()));
    return this;
  }
}
