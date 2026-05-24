# Feature Modules

## lib/features/

### app/ - Core App Features
- **Presentation**: [`skarnik_app.dart`](lib/features/app/presentation/skarnik_app.dart), [`skarnik_router.dart`](lib/features/app/presentation/skarnik_router.dart), [`skarnik_app_bloc.dart`](lib/features/app/presentation/skarnik_app_bloc.dart)
- **Domain**: [`dictionary.dart`](lib/features/app/domain/entity/dictionary.dart), [`word.dart`](lib/features/app/domain/entity/word.dart), use cases for init/analytics
- **Data**: ObjectBox repositories and models

### home/ - History Tab
- **Presentation**: [`home_page.dart`](lib/features/home/presentation/home_page.dart)
- **Domain**: [`load_history.dart`](lib/features/home/domain/use_case/load_history.dart)

### search/ - Search Feature
- **Presentation**: [`search_cubit.dart`](lib/features/search/presentation/search_cubit.dart), [`search_page.dart`](lib/features/search/presentation/search_page.dart)
- **Domain**: [`search_use_case.dart`](lib/features/search/domain/use_case/search_use_case.dart)
- **Data**: ObjectBox search repository

### translation/ - Translation Detail
- **Presentation**: [`translation_cubit.dart`](lib/features/translation/presentation/translation_cubit.dart), [`translation_page.dart`](lib/features/translation/presentation/translation_page.dart)
- **Domain**: Translation, favorites, history use cases
- **Data**: API repository, ObjectBox repositories, Dio HTTP client

### favorites/ - Bookmarks
- **Presentation**: [`favorites_cubit.dart`](lib/features/favorites/presentation/favorites_cubit.dart), [`favorites_page.dart`](lib/features/favorites/presentation/favorites_page.dart)
- **Domain**: [`load_favorites.dart`](lib/features/favorites/domain/use_case/load_favorites.dart)

### vocabulary/ - Dictionary Browse
- **Presentation**: [`vocabulary_cubit.dart`](lib/features/vocabulary/presentation/vocabulary_cubit.dart), [`vocabulary_page.dart`](lib/features/vocabulary/presentation/vocabulary_page.dart)
- **Domain**: [`load_vocabulary.dart`](lib/features/vocabulary/domain/use_case/load_vocabulary.dart)

### settings/ - App Settings
- **Presentation**: [`settings_cubit.dart`](lib/features/settings/presentation/settings_cubit.dart), [`settings_page.dart`](lib/features/settings/presentation/settings_page.dart)
- **Domain**: [`clear_history.dart`](lib/features/settings/domain/use_case/clear_history.dart)

---

# Key Files Quick Reference

## Entry Points
- [`lib/main.dart`](lib/main.dart) - App bootstrap, Firebase init

## Configuration
- [`lib/app_config.dart`](lib/app_config.dart) - Constants (API host, page sizes)
- [`lib/strings.dart`](lib/strings.dart) - Belarusian UI strings
- [`lib/di.skarnik.config.dart`](lib/di.skarnik.config.dart) - Dependency injection

## Core
- [`lib/core/base_use_case.dart`](lib/core/base_use_case.dart) - Success/Failure result types
- [`lib/core/exceptions.dart`](lib/core/exceptions.dart) - Custom exceptions

## Domain Entities
- [`lib/features/app/domain/entity/dictionary.dart`](lib/features/app/domain/entity/dictionary.dart) - Dictionary enum
- [`lib/features/app/domain/entity/word.dart`](lib/features/app/domain/entity/word.dart) - Word entity
- [`lib/features/app/domain/entity/search_word.dart`](lib/features/app/domain/entity/search_word.dart) - SearchWord interface

## ObjectBox Models
- [`lib/features/app/data/model/objectbox_search_word.dart`](lib/features/app/data/model/objectbox_search_word.dart)
- [`lib/features/app/data/model/objectbox_favorite_word.dart`](lib/features/app/data/model/objectbox_favorite_word.dart)
- [`lib/features/app/data/model/objectbox_history_word.dart`](lib/features/app/data/model/objectbox_history_word.dart)

## Use Cases (by Feature)
- **Translation**: GetTranslation, GetWord, AddToFavorites, RemoveFromFavorites, CheckInFavorites, SaveToHistory
- **Search**: SearchUseCase
- **Vocabulary**: LoadVocabulary
- **Favorites**: LoadFavorites
- **Settings**: ClearHistory
- **App**: InitDatabase, InitRemoteConfig, HandleAppLink

## Cubits/Blocs
- SkarnikAppBloc, TranslationCubit, SearchCubit, VocabularyCubit, FavoritesCubit, HistoryCubit, SettingsCubit

## Repositories
- **API**: ApiTranslationRepository → ApiTranslationRepositoryImpl (Dio)
- **Local**: ObjectBox implementations for Search, Favorites, History, Vocabulary, Settings
- **Analytics**: Firebase/Dev implementations

## HTTP
- [`lib/features/translation/data/http/skarnik_dio.dart`](lib/features/translation/data/http/skarnik_dio.dart) - Configured Dio instance
