// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:skarnik_flutter/features/app/data/repository/dev_analytics_app_repository.dart'
    as _i805;
import 'package:skarnik_flutter/features/app/data/repository/firebase_analytics_app_repository.dart'
    as _i1004;
import 'package:skarnik_flutter/features/app/data/repository/objectbox_database_repository.dart'
    as _i226;
import 'package:skarnik_flutter/features/app/data/service/objectbox_store_holder.dart'
    as _i522;
import 'package:skarnik_flutter/features/app/domain/repository/analytics_app_repository.dart'
    as _i71;
import 'package:skarnik_flutter/features/app/domain/repository/database_repository.dart'
    as _i763;
import 'package:skarnik_flutter/features/app/domain/use_case/get_app_link_stream.dart'
    as _i519;
import 'package:skarnik_flutter/features/app/domain/use_case/handle_app_link.dart'
    as _i590;
import 'package:skarnik_flutter/features/app/domain/use_case/init_database.dart'
    as _i146;
import 'package:skarnik_flutter/features/app/domain/use_case/init_remote_config.dart'
    as _i525;
import 'package:skarnik_flutter/features/app/domain/use_case/log_analytics_app_started.dart'
    as _i958;
import 'package:skarnik_flutter/features/favorites/domain/use_case/load_favorites.dart'
    as _i978;
import 'package:skarnik_flutter/features/home/domain/use_case/load_history.dart'
    as _i522;
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart'
    as _i578;
import 'package:skarnik_flutter/features/search/data/repository/query_repository_impl.dart'
    as _i613;
import 'package:skarnik_flutter/features/search/domain/repository/query_repository.dart'
    as _i264;
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart'
    as _i124;
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart'
    as _i915;
import 'package:skarnik_flutter/features/settings/data/repository/objectbox_settings_history_repository.dart'
    as _i252;
import 'package:skarnik_flutter/features/settings/domain/repository/settings_history_repository.dart'
    as _i531;
import 'package:skarnik_flutter/features/settings/domain/use_case/clear_history.dart'
    as _i861;
import 'package:skarnik_flutter/features/translation/data/http/skarnik_dio.dart'
    as _i485;
import 'package:skarnik_flutter/features/translation/data/repository/api_translation_repository_impl.dart'
    as _i172;
import 'package:skarnik_flutter/features/translation/data/repository/dev_analytics_translation_repository.dart'
    as _i336;
import 'package:skarnik_flutter/features/translation/data/repository/firebase_analytics_translation_repository.dart'
    as _i646;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_favorites_repository.dart'
    as _i792;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_history_repository.dart'
    as _i556;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_word_repository.dart'
    as _i326;
import 'package:skarnik_flutter/features/translation/data/repository/skarnik_translation_repository.dart'
    as _i779;
import 'package:skarnik_flutter/features/translation/domain/repository/analytics_translation_repository.dart'
    as _i223;
import 'package:skarnik_flutter/features/translation/domain/repository/api_translation_repository.dart'
    as _i138;
import 'package:skarnik_flutter/features/translation/domain/repository/favorites_repository.dart'
    as _i361;
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart'
    as _i788;
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart'
    as _i507;
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart'
    as _i147;
import 'package:skarnik_flutter/features/translation/domain/use_case/add_to_favorites.dart'
    as _i311;
import 'package:skarnik_flutter/features/translation/domain/use_case/check_in_favorites.dart'
    as _i135;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart'
    as _i803;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_word.dart'
    as _i914;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_add_to_favorites.dart'
    as _i135;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_share.dart'
    as _i888;
import 'package:skarnik_flutter/features/translation/domain/use_case/log_analytics_translation.dart'
    as _i501;
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart'
    as _i235;
import 'package:skarnik_flutter/features/translation/domain/use_case/save_to_history.dart'
    as _i276;
import 'package:skarnik_flutter/features/vocabulary/data/repository/dev_analytics_vocabulary_repository.dart'
    as _i989;
import 'package:skarnik_flutter/features/vocabulary/data/repository/firebase_analytics_vocabulary_repository.dart'
    as _i20;
import 'package:skarnik_flutter/features/vocabulary/data/repository/vocabulary_repository.dart'
    as _i609;
import 'package:skarnik_flutter/features/vocabulary/domain/repository/analytics_vocabulary_repository.dart'
    as _i267;
import 'package:skarnik_flutter/features/vocabulary/domain/repository/vocabulary_repository.dart'
    as _i587;
import 'package:skarnik_flutter/features/vocabulary/domain/use_case/load_vocabulary.dart'
    as _i741;
import 'package:skarnik_flutter/features/vocabulary/domain/use_case/log_analytics_vocabulary_word.dart'
    as _i616;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i519.GetAppLinkStreamUseCase>(
        () => _i519.GetAppLinkStreamUseCase());
    gh.factory<_i525.InitRemoteConfigUseCase>(
        () => _i525.InitRemoteConfigUseCase());
    gh.factory<_i590.HandleAppLinkUseCase>(() => _i590.HandleAppLinkUseCase());
    gh.factory<_i267.AnalyticsVocabularyRepository>(
      () => _i989.DevAnalyticsVocabularyRepository(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i361.Dio>(() => _i485.SkarnikDio());
    gh.factory<_i71.AnalyticsAppRepository>(
      () => _i805.DevAnalyticsAppRepository(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i138.ApiTranslationRepository>(
        () => _i172.ApiTranslationRepositoryImpl(gh<_i361.Dio>()));
    gh.factory<_i147.WordRepository>(
        () => _i326.ObjectboxWordRepository(gh<_i522.ObjectboxStoreHolder>()));
    gh.factory<_i763.DatabaseRepository>(
        () => _i226.ObjectboxDatabaseRepository());
    gh.factory<_i223.AnalyticsTranslationRepository>(
      () => _i336.DevAnalyticsTranslationRepository(),
      registerFor: {_dev},
    );
    gh.factory<_i507.FallbackTranslationRepository>(
        () => _i779.SkarnikTranslationRepository(gh<_i361.Dio>()));
    gh.factory<_i914.GetWordUseCase>(
        () => _i914.GetWordUseCase(gh<_i147.WordRepository>()));
    gh.factory<_i587.VocabularyRepository>(() =>
        _i609.ObjectboxVocabularyRepository(gh<_i522.ObjectboxStoreHolder>()));
    gh.factory<_i803.GetTranslationUseCase>(() => _i803.GetTranslationUseCase(
          apiWordRepository: gh<_i138.ApiTranslationRepository>(),
          fallbackTranslationRepository:
              gh<_i507.FallbackTranslationRepository>(),
        ));
    gh.factory<_i71.AnalyticsAppRepository>(
      () => _i1004.FirebaseAnalyticsAppRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i788.HistoryRepository>(() =>
        _i556.ObjectboxHistoryRepository(gh<_i522.ObjectboxStoreHolder>()));
    gh.factory<_i361.FavoritesRepository>(() =>
        _i792.ObjectboxFavoritesRepository(gh<_i522.ObjectboxStoreHolder>()));
    gh.lazySingleton<_i264.QueryRepository>(
        () => _i613.QueryRepositoryImpl(gh<_i522.ObjectboxStoreHolder>()));
    gh.lazySingleton<_i124.SearchRepository>(
        () => _i578.ObjectboxSearchRepository(gh<_i264.QueryRepository>()));
    gh.factory<_i146.InitDatabaseUseCase>(
        () => _i146.InitDatabaseUseCase(gh<_i763.DatabaseRepository>()));
    gh.factory<_i616.LogAnalyticsVocabularyWordUseCase>(() =>
        _i616.LogAnalyticsVocabularyWordUseCase(
            gh<_i267.AnalyticsVocabularyRepository>()));
    gh.factory<_i223.AnalyticsTranslationRepository>(
      () => _i646.FirebaseAnalyticsTranslationRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i531.SettingsHistoryRepository>(() =>
        _i252.ObjectboxSettingsHistoryRepository(
            gh<_i522.ObjectboxStoreHolder>()));
    gh.factory<_i267.AnalyticsVocabularyRepository>(
      () => _i20.FirebaseAnalyticsVocabularyRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i741.LoadVocabularyUseCase>(
        () => _i741.LoadVocabularyUseCase(gh<_i587.VocabularyRepository>()));
    gh.factory<_i276.SaveToHistoryUseCase>(
        () => _i276.SaveToHistoryUseCase(gh<_i788.HistoryRepository>()));
    gh.factory<_i522.LoadHistoryUseCase>(
        () => _i522.LoadHistoryUseCase(gh<_i788.HistoryRepository>()));
    gh.factory<_i958.LogAnalyticsAppOpenUseCase>(() =>
        _i958.LogAnalyticsAppOpenUseCase(gh<_i71.AnalyticsAppRepository>()));
    gh.factory<_i915.SearchUseCase>(
        () => _i915.SearchUseCase(gh<_i124.SearchRepository>()));
    gh.factory<_i311.AddToFavoritesUseCase>(
        () => _i311.AddToFavoritesUseCase(gh<_i361.FavoritesRepository>()));
    gh.factory<_i135.CheckInFavoritesUseCase>(
        () => _i135.CheckInFavoritesUseCase(gh<_i361.FavoritesRepository>()));
    gh.factory<_i235.RemoveFromFavoritesUseCase>(() =>
        _i235.RemoveFromFavoritesUseCase(gh<_i361.FavoritesRepository>()));
    gh.factory<_i978.LoadFavoritesUseCase>(
        () => _i978.LoadFavoritesUseCase(gh<_i361.FavoritesRepository>()));
    gh.factory<_i861.ClearHistoryUseCase>(
        () => _i861.ClearHistoryUseCase(gh<_i531.SettingsHistoryRepository>()));
    gh.factory<_i501.LogAnalyticsTranslationUseCase>(() =>
        _i501.LogAnalyticsTranslationUseCase(
            gh<_i223.AnalyticsTranslationRepository>()));
    gh.factory<_i135.LogAnalyticsAddToFavoritesUseCase>(() =>
        _i135.LogAnalyticsAddToFavoritesUseCase(
            gh<_i223.AnalyticsTranslationRepository>()));
    gh.factory<_i888.LogAnalyticsShareUseCase>(() =>
        _i888.LogAnalyticsShareUseCase(
            gh<_i223.AnalyticsTranslationRepository>()));
    return this;
  }
}
