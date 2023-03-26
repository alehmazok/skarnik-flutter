// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:skarnik_flutter/features/app/data/repository/objectbox_database_repository.dart'
    as _i4;
import 'package:skarnik_flutter/features/app/data/service/objectbox_service.dart'
    as _i7;
import 'package:skarnik_flutter/features/app/domain/repository/database_repository.dart'
    as _i3;
import 'package:skarnik_flutter/features/app/domain/use_case/init_database.dart'
    as _i10;
import 'package:skarnik_flutter/features/app/domain/use_case/init_remote_config.dart'
    as _i11;
import 'package:skarnik_flutter/features/history/data/repository/objectbox_history_repository.dart'
    as _i9;
import 'package:skarnik_flutter/features/history/domain/repository/history_repository.dart'
    as _i8;
import 'package:skarnik_flutter/features/history/domain/use_case/load_history.dart'
    as _i12;
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart'
    as _i15;
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart'
    as _i14;
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart'
    as _i16;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_history_repository.dart'
    as _i6;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_word_repository.dart'
    as _i20;
import 'package:skarnik_flutter/features/translation/data/repository/skarnik_translation_repository.dart'
    as _i18;
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart'
    as _i5;
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart'
    as _i17;
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart'
    as _i19;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart'
    as _i21;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_word.dart'
    as _i22;
import 'package:skarnik_flutter/features/translation/domain/use_case/save_to_history.dart'
    as _i13; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
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
    gh.factory<_i5.HistoryRepository>(
        () => _i6.ObjectboxHistoryRepository(gh<_i7.ObjectboxService>()));
    gh.factory<_i8.HistoryRepository>(
        () => _i9.ObjectboxHistoryRepository(gh<_i7.ObjectboxService>()));
    gh.factory<_i10.InitDatabaseUseCase>(
        () => _i10.InitDatabaseUseCase(gh<_i3.DatabaseRepository>()));
    gh.factory<_i11.InitRemoteConfigUseCase>(
        () => _i11.InitRemoteConfigUseCase());
    gh.factory<_i12.LoadHistoryUseCase>(
        () => _i12.LoadHistoryUseCase(gh<_i8.HistoryRepository>()));
    gh.factory<_i13.SaveToHistoryUseCase>(
        () => _i13.SaveToHistoryUseCase(gh<_i5.HistoryRepository>()));
    gh.factory<_i14.SearchRepository>(
        () => _i15.ObjectboxSearchRepository(gh<_i7.ObjectboxService>()));
    gh.factory<_i16.SearchUseCase>(
        () => _i16.SearchUseCase(gh<_i14.SearchRepository>()));
    gh.factory<_i17.TranslationRepository>(
        () => _i18.SkarnikTranslationRepository());
    gh.factory<_i19.WordRepository>(
        () => _i20.ObjectboxWordRepository(gh<_i7.ObjectboxService>()));
    gh.factory<_i21.GetTranslationUseCase>(
        () => _i21.GetTranslationUseCase(gh<_i17.TranslationRepository>()));
    gh.factory<_i22.GetWordUseCase>(
        () => _i22.GetWordUseCase(gh<_i19.WordRepository>()));
    return this;
  }
}
