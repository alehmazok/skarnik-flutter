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
    as _i9;
import 'package:skarnik_flutter/features/app/domain/repository/database_repository.dart'
    as _i3;
import 'package:skarnik_flutter/features/app/domain/use_case/init_database.dart'
    as _i5;
import 'package:skarnik_flutter/features/app/domain/use_case/init_remote_config.dart'
    as _i6;
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart'
    as _i8;
import 'package:skarnik_flutter/features/search/domain/repository/search_repository.dart'
    as _i7;
import 'package:skarnik_flutter/features/search/domain/use_case/search_use_case.dart'
    as _i10;
import 'package:skarnik_flutter/features/translation/data/repository/objectbox_word_repository.dart'
    as _i14;
import 'package:skarnik_flutter/features/translation/data/repository/skarnik_translation_repository.dart'
    as _i12;
import 'package:skarnik_flutter/features/translation/domain/repository/translation_repository.dart'
    as _i11;
import 'package:skarnik_flutter/features/translation/domain/repository/word_repository.dart'
    as _i13;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_translation.dart'
    as _i15;
import 'package:skarnik_flutter/features/translation/domain/use_case/get_word.dart'
    as _i16; // ignore_for_file: unnecessary_lambdas

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
    gh.factory<_i5.InitDatabaseUseCase>(
        () => _i5.InitDatabaseUseCase(gh<_i3.DatabaseRepository>()));
    gh.factory<_i6.InitRemoteConfigUseCase>(
        () => _i6.InitRemoteConfigUseCase());
    gh.factory<_i7.SearchRepository>(
        () => _i8.ObjectboxSearchRepository(gh<_i9.ObjectboxService>()));
    gh.factory<_i10.SearchUseCase>(
        () => _i10.SearchUseCase(gh<_i7.SearchRepository>()));
    gh.factory<_i11.TranslationRepository>(
        () => _i12.SkarnikTranslationRepository());
    gh.factory<_i13.WordRepository>(
        () => _i14.ObjectboxWordRepository(gh<_i9.ObjectboxService>()));
    gh.factory<_i15.GetTranslationUseCase>(
        () => _i15.GetTranslationUseCase(gh<_i11.TranslationRepository>()));
    gh.factory<_i16.GetWordUseCase>(
        () => _i16.GetWordUseCase(gh<_i13.WordRepository>()));
    return this;
  }
}
