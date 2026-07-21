// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

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
import 'package:skarnik_flutter/features/favorites/data/repository/shared_preferences_favorites_sort_repository.dart'
    as _i1037;
import 'package:skarnik_flutter/features/favorites/domain/repository/favorites_sort_repository.dart'
    as _i636;
import 'package:skarnik_flutter/features/favorites/domain/use_case/load_favorites.dart'
    as _i978;
import 'package:skarnik_flutter/features/home/domain/use_case/load_history.dart'
    as _i522;
import 'package:skarnik_flutter/features/review/data/repository/shared_preferences_review_repository.dart'
    as _i543;
import 'package:skarnik_flutter/features/review/domain/repository/review_repository.dart'
    as _i806;
import 'package:skarnik_flutter/features/review/domain/use_case/check_and_request_review.dart'
    as _i754;
import 'package:skarnik_flutter/features/search/data/repository/dev_analytics_search_repository.dart'
    as _i772;
import 'package:skarnik_flutter/features/search/data/repository/firebase_analytics_search_repository.dart'
    as _i536;
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart'
    as _i578;
import 'package:skarnik_flutter/features/search/data/repository/query_repository_impl.dart'
    as _i613;
import 'package:skarnik_flutter/features/search/domain/repository/analytics_search_repository.dart'
    as _i994;
import 'package:skarnik_flutter/features/search/domain/repository/query_repository.dart'
    as _i264;
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart'
    as _i124;
import 'package:skarnik_flutter/features/search/domain/use_case/log_analytics_search_no_results.dart'
    as _i369;
import 'package:skarnik_flutter/features/search/domain/use_case/log_analytics_search_performed.dart'
    as _i846;
import 'package:skarnik_flutter/features/search/domain/use_case/log_analytics_search_result_tapped.dart'
    as _i765;
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart'
    as _i915;
import 'package:skarnik_flutter/features/settings/data/repository/dev_analytics_settings_repository.dart'
    as _i1018;
import 'package:skarnik_flutter/features/settings/data/repository/firebase_analytics_settings_repository.dart'
    as _i383;
import 'package:skarnik_flutter/features/settings/data/repository/objectbox_settings_history_repository.dart'
    as _i252;
import 'package:skarnik_flutter/features/settings/data/repository/shared_preferences_offline_dictionaries_promo_repository.dart'
    as _i232;
import 'package:skarnik_flutter/features/settings/domain/repository/analytics_settings_repository.dart'
    as _i924;
import 'package:skarnik_flutter/features/settings/domain/repository/offline_dictionaries_promo_repository.dart'
    as _i240;
import 'package:skarnik_flutter/features/settings/domain/repository/settings_history_repository.dart'
    as _i531;
import 'package:skarnik_flutter/features/settings/domain/use_case/clear_history.dart'
    as _i861;
import 'package:skarnik_flutter/features/settings/domain/use_case/log_analytics_dictionary_download.dart'
    as _i263;
import 'package:skarnik_flutter/features/settings/presentation/offline_dictionaries_cubit.dart'
    as _i253;
import 'package:skarnik_flutter/features/settings/presentation/offline_dictionaries_promo_cubit.dart'
    as _i951;
import 'package:skarnik_flutter/features/stress/data/repository/api_stress_repository_impl.dart'
    as _i795;
import 'package:skarnik_flutter/features/stress/data/repository/dev_analytics_stress_repository.dart'
    as _i410;
import 'package:skarnik_flutter/features/stress/data/repository/firebase_analytics_stress_repository.dart'
    as _i51;
import 'package:skarnik_flutter/features/stress/data/repository/starnik_stress_repository.dart'
    as _i370;
import 'package:skarnik_flutter/features/stress/domain/repository/analytics_stress_repository.dart'
    as _i173;
import 'package:skarnik_flutter/features/stress/domain/repository/cloud_stress_repository.dart'
    as _i297;
import 'package:skarnik_flutter/features/stress/domain/repository/stress_repository.dart'
    as _i670;
import 'package:skarnik_flutter/features/stress/domain/use_case/get_stress_table.dart'
    as _i468;
import 'package:skarnik_flutter/features/stress/domain/use_case/log_analytics_stress.dart'
    as _i240;
import 'package:skarnik_flutter/features/stress/domain/use_case/resolve_stress_word_list.dart'
    as _i407;
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
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_translation_repository.dart'
    as _i395;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_word_repository.dart'
    as _i326;
import 'package:skarnik_flutter/features/translation/data/repository/shared_preferences_download_cursor_repository.dart'
    as _i278;
import 'package:skarnik_flutter/features/translation/data/repository/shared_preferences_download_rate_limit_repository.dart'
    as _i877;
import 'package:skarnik_flutter/features/translation/data/repository/skarnik_translation_repository.dart'
    as _i779;
import 'package:skarnik_flutter/features/translation/data/repository/supabase_api_translation_repository_impl.dart'
    as _i1072;
import 'package:skarnik_flutter/features/translation/domain/repository/analytics_translation_repository.dart'
    as _i223;
import 'package:skarnik_flutter/features/translation/domain/repository/api_translation_repository.dart'
    as _i138;
import 'package:skarnik_flutter/features/translation/domain/repository/cloud_translation_repository.dart'
    as _i361;
import 'package:skarnik_flutter/features/translation/domain/repository/download_cursor_repository.dart'
    as _i978;
import 'package:skarnik_flutter/features/translation/domain/repository/download_rate_limit_repository.dart'
    as _i1028;
import 'package:skarnik_flutter/features/translation/domain/repository/favorites_repository.dart'
    as _i361;
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart'
    as _i788;
import 'package:skarnik_flutter/features/translation/domain/repository/local_translation_repository.dart'
    as _i554;
import 'package:skarnik_flutter/features/translation/domain/repository/website_translation_repository.dart'
    as _i317;
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart'
    as _i147;
import 'package:skarnik_flutter/features/translation/domain/use_case/add_to_favorites.dart'
    as _i311;
import 'package:skarnik_flutter/features/translation/domain/use_case/check_download_rate_limit.dart'
    as _i358;
import 'package:skarnik_flutter/features/translation/domain/use_case/check_in_favorites.dart'
    as _i135;
import 'package:skarnik_flutter/features/translation/domain/use_case/clear_downloaded_dictionary.dart'
    as _i118;
import 'package:skarnik_flutter/features/translation/domain/use_case/count_downloaded_words.dart'
    as _i883;
import 'package:skarnik_flutter/features/translation/domain/use_case/download_dictionary.dart'
    as _i705;
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
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i519.GetAppLinkStreamUseCase>(
      () => _i519.GetAppLinkStreamUseCase(),
    );
    gh.factory<_i590.HandleAppLinkUseCase>(() => _i590.HandleAppLinkUseCase());
    gh.factory<_i525.InitRemoteConfigUseCase>(
      () => _i525.InitRemoteConfigUseCase(),
    );
    gh.factory<_i978.DownloadCursorRepository>(
      () => _i278.SharedPreferencesDownloadCursorRepository(),
    );
    gh.factory<_i267.AnalyticsVocabularyRepository>(
      () => _i989.DevAnalyticsVocabularyRepository(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i361.CloudTranslationRepository>(
      () => _i1072.SupabaseTranslationRepositoryImpl(),
    );
    gh.lazySingleton<_i361.Dio>(() => _i485.SkarnikDio());
    gh.factory<_i636.FavoritesSortRepository>(
      () => _i1037.SharedPreferencesFavoritesSortRepository(),
    );
    gh.factory<_i994.AnalyticsSearchRepository>(
      () => _i772.DevAnalyticsSearchRepository(),
      registerFor: {_dev},
    );
    gh.factory<_i71.AnalyticsAppRepository>(
      () => _i805.DevAnalyticsAppRepository(),
      registerFor: {_dev},
    );
    gh.factory<_i531.SettingsHistoryRepository>(
      () => _i252.ObjectboxSettingsHistoryRepository(
        gh<_i522.ObjectboxStoreHolder>(),
      ),
    );
    gh.factory<_i763.DatabaseRepository>(
      () => _i226.ObjectboxDatabaseRepository(),
    );
    gh.factory<_i223.AnalyticsTranslationRepository>(
      () => _i336.DevAnalyticsTranslationRepository(),
      registerFor: {_dev},
    );
    gh.factory<_i240.OfflineDictionariesPromoRepository>(
      () => _i232.SharedPreferencesOfflineDictionariesPromoRepository(),
    );
    gh.factory<_i173.AnalyticsStressRepository>(
      () => _i410.DevAnalyticsStressRepository(),
      registerFor: {_dev},
    );
    gh.factory<_i806.ReviewRepository>(
      () => _i543.SharedPreferencesReviewRepository(),
    );
    gh.factory<_i587.VocabularyRepository>(
      () =>
          _i609.ObjectboxVocabularyRepository(gh<_i522.ObjectboxStoreHolder>()),
    );
    gh.factory<_i924.AnalyticsSettingsRepository>(
      () => _i1018.DevAnalyticsSettingsRepository(),
      registerFor: {_dev},
    );
    gh.factory<_i670.StressRepository>(
      () => _i370.StarnikStressRepository(gh<_i361.Dio>()),
    );
    gh.factory<_i1028.DownloadRateLimitRepository>(
      () => _i877.SharedPreferencesDownloadRateLimitRepository(),
    );
    gh.factory<_i358.CheckDownloadRateLimitUseCase>(
      () => _i358.CheckDownloadRateLimitUseCase(
        gh<_i1028.DownloadRateLimitRepository>(),
      ),
    );
    gh.lazySingleton<_i264.QueryRepository>(
      () => _i613.QueryRepositoryImpl(gh<_i522.ObjectboxStoreHolder>()),
    );
    gh.factory<_i71.AnalyticsAppRepository>(
      () => _i1004.FirebaseAnalyticsAppRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i741.LoadVocabularyUseCase>(
      () => _i741.LoadVocabularyUseCase(gh<_i587.VocabularyRepository>()),
    );
    gh.factory<_i994.AnalyticsSearchRepository>(
      () => _i536.FirebaseAnalyticsSearchRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i173.AnalyticsStressRepository>(
      () => _i51.FirebaseAnalyticsStressRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i924.AnalyticsSettingsRepository>(
      () => _i383.FirebaseAnalyticsSettingsRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i263.LogAnalyticsDictionaryDownloadUseCase>(
      () => _i263.LogAnalyticsDictionaryDownloadUseCase(
        gh<_i924.AnalyticsSettingsRepository>(),
      ),
    );
    gh.factory<_i958.LogAnalyticsAppOpenUseCase>(
      () => _i958.LogAnalyticsAppOpenUseCase(gh<_i71.AnalyticsAppRepository>()),
    );
    gh.factory<_i788.HistoryRepository>(
      () => _i556.ObjectboxHistoryRepository(gh<_i522.ObjectboxStoreHolder>()),
    );
    gh.factory<_i861.ClearHistoryUseCase>(
      () => _i861.ClearHistoryUseCase(gh<_i531.SettingsHistoryRepository>()),
    );
    gh.factory<_i361.FavoritesRepository>(
      () =>
          _i792.ObjectboxFavoritesRepository(gh<_i522.ObjectboxStoreHolder>()),
    );
    gh.factory<_i554.LocalTranslationRepository>(
      () => _i395.ObjectboxTranslationRepository(
        gh<_i522.ObjectboxStoreHolder>(),
      ),
    );
    gh.factory<_i146.InitDatabaseUseCase>(
      () => _i146.InitDatabaseUseCase(gh<_i763.DatabaseRepository>()),
    );
    gh.factory<_i223.AnalyticsTranslationRepository>(
      () => _i646.FirebaseAnalyticsTranslationRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i118.ClearDownloadedDictionaryUseCase>(
      () => _i118.ClearDownloadedDictionaryUseCase(
        gh<_i554.LocalTranslationRepository>(),
        gh<_i978.DownloadCursorRepository>(),
      ),
    );
    gh.factory<_i267.AnalyticsVocabularyRepository>(
      () => _i20.FirebaseAnalyticsVocabularyRepository(),
      registerFor: {_prod},
    );
    gh.factory<_i705.DownloadDictionaryUseCase>(
      () => _i705.DownloadDictionaryUseCase(
        cloudTranslationRepository: gh<_i361.CloudTranslationRepository>(),
        localTranslationRepository: gh<_i554.LocalTranslationRepository>(),
        downloadCursorRepository: gh<_i978.DownloadCursorRepository>(),
      ),
    );
    gh.factory<_i147.WordRepository>(
      () => _i326.ObjectboxWordRepository(gh<_i522.ObjectboxStoreHolder>()),
    );
    gh.factory<_i317.WebsiteTranslationRepository>(
      () => _i779.SkarnikTranslationRepository(gh<_i361.Dio>()),
    );
    gh.factory<_i522.LoadHistoryUseCase>(
      () => _i522.LoadHistoryUseCase(gh<_i788.HistoryRepository>()),
    );
    gh.factory<_i276.SaveToHistoryUseCase>(
      () => _i276.SaveToHistoryUseCase(gh<_i788.HistoryRepository>()),
    );
    gh.lazySingleton<_i297.CloudStressRepository>(
      () => _i795.ApiStressRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i138.ApiTranslationRepository>(
      () => _i172.ApiTranslationRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i754.CheckAndRequestReviewUseCase>(
      () => _i754.CheckAndRequestReviewUseCase(gh<_i806.ReviewRepository>()),
    );
    gh.lazySingleton<_i951.OfflineDictionariesPromoCubit>(
      () => _i951.OfflineDictionariesPromoCubit(
        gh<_i240.OfflineDictionariesPromoRepository>(),
      ),
    );
    gh.factory<_i978.LoadFavoritesUseCase>(
      () => _i978.LoadFavoritesUseCase(gh<_i361.FavoritesRepository>()),
    );
    gh.factory<_i311.AddToFavoritesUseCase>(
      () => _i311.AddToFavoritesUseCase(gh<_i361.FavoritesRepository>()),
    );
    gh.factory<_i135.CheckInFavoritesUseCase>(
      () => _i135.CheckInFavoritesUseCase(gh<_i361.FavoritesRepository>()),
    );
    gh.factory<_i235.RemoveFromFavoritesUseCase>(
      () => _i235.RemoveFromFavoritesUseCase(gh<_i361.FavoritesRepository>()),
    );
    gh.factory<_i914.GetWordUseCase>(
      () => _i914.GetWordUseCase(gh<_i147.WordRepository>()),
    );
    gh.factory<_i369.LogAnalyticsSearchNoResultsUseCase>(
      () => _i369.LogAnalyticsSearchNoResultsUseCase(
        gh<_i994.AnalyticsSearchRepository>(),
      ),
    );
    gh.factory<_i846.LogAnalyticsSearchPerformedUseCase>(
      () => _i846.LogAnalyticsSearchPerformedUseCase(
        gh<_i994.AnalyticsSearchRepository>(),
      ),
    );
    gh.factory<_i765.LogAnalyticsSearchResultTappedUseCase>(
      () => _i765.LogAnalyticsSearchResultTappedUseCase(
        gh<_i994.AnalyticsSearchRepository>(),
      ),
    );
    gh.factory<_i616.LogAnalyticsVocabularyWordUseCase>(
      () => _i616.LogAnalyticsVocabularyWordUseCase(
        gh<_i267.AnalyticsVocabularyRepository>(),
      ),
    );
    gh.lazySingleton<_i124.SearchRepository>(
      () => _i578.ObjectboxSearchRepository(gh<_i264.QueryRepository>()),
    );
    gh.factory<_i468.GetStressTableUseCase>(
      () => _i468.GetStressTableUseCase(
        gh<_i670.StressRepository>(),
        gh<_i297.CloudStressRepository>(),
      ),
    );
    gh.factory<_i407.ResolveStressWordListUseCase>(
      () => _i407.ResolveStressWordListUseCase(
        gh<_i670.StressRepository>(),
        gh<_i297.CloudStressRepository>(),
      ),
    );
    gh.factory<_i240.LogAnalyticsStressUseCase>(
      () => _i240.LogAnalyticsStressUseCase(
        gh<_i173.AnalyticsStressRepository>(),
      ),
    );
    gh.factory<_i803.GetTranslationUseCase>(
      () => _i803.GetTranslationUseCase(
        localTranslationRepository: gh<_i554.LocalTranslationRepository>(),
        apiWordRepository: gh<_i138.ApiTranslationRepository>(),
        cloudTranslationRepository: gh<_i361.CloudTranslationRepository>(),
        websiteTranslationRepository: gh<_i317.WebsiteTranslationRepository>(),
      ),
    );
    gh.factory<_i135.LogAnalyticsAddToFavoritesUseCase>(
      () => _i135.LogAnalyticsAddToFavoritesUseCase(
        gh<_i223.AnalyticsTranslationRepository>(),
      ),
    );
    gh.factory<_i888.LogAnalyticsShareUseCase>(
      () => _i888.LogAnalyticsShareUseCase(
        gh<_i223.AnalyticsTranslationRepository>(),
      ),
    );
    gh.factory<_i501.LogAnalyticsTranslationUseCase>(
      () => _i501.LogAnalyticsTranslationUseCase(
        gh<_i223.AnalyticsTranslationRepository>(),
      ),
    );
    gh.factory<_i883.CountDownloadedWordsUseCase>(
      () => _i883.CountDownloadedWordsUseCase(
        gh<_i554.LocalTranslationRepository>(),
      ),
    );
    gh.factory<_i915.SearchUseCase>(
      () => _i915.SearchUseCase(gh<_i124.SearchRepository>()),
    );
    gh.lazySingleton<_i253.OfflineDictionariesCubit>(
      () => _i253.OfflineDictionariesCubit(
        downloadDictionaryUseCase: gh<_i705.DownloadDictionaryUseCase>(),
        clearDownloadedDictionaryUseCase:
            gh<_i118.ClearDownloadedDictionaryUseCase>(),
        countDownloadedWordsUseCase: gh<_i883.CountDownloadedWordsUseCase>(),
        checkDownloadRateLimitUseCase:
            gh<_i358.CheckDownloadRateLimitUseCase>(),
        logAnalyticsDictionaryDownloadUseCase:
            gh<_i263.LogAnalyticsDictionaryDownloadUseCase>(),
      ),
    );
    return this;
  }
}
