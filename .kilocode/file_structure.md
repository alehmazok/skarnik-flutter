# File Structure Reference

```
lib/
├── app_config.dart              # App-wide configuration constants
├── bloc_observer.dart           # BLoC observer for debugging
├── di.skarnik.config.dart       # Generated DI configuration
├── di.skarnik.dart              # DI setup entry
├── firebase_options.dart         # Firebase configuration
├── logging.dart                 # Logging setup
├── main.dart                    # App entry point
├── objectbox-model.json         # ObjectBox model definition
├── objectbox.g.dart             # Generated ObjectBox code
├── serializers.dart             # BuiltValue serializers
├── serializers.g.dart           # Generated serializers
├── strings.dart                 # Belarusian UI strings
│
├── core/
│   ├── base_use_case.dart       # UseCaseResult (Success/Failure)
│   ├── exceptions.dart          # Custom exceptions
│   └── extensions.dart          # Dart extensions
│
├── features/
│   ├── app/                     # Core app features
│   │   ├── data/
│   │   │   ├── model/
│   │   │   │   ├── objectbox_favorite_word.dart
│   │   │   │   ├── objectbox_history_word.dart
│   │   │   │   └── objectbox_search_word.dart
│   │   │   ├── repository/
│   │   │   │   ├── dev_analytics_app_repository.dart
│   │   │   │   ├── firebase_analytics_app_repository.dart
│   │   │   │   └── objectbox_database_repository.dart
│   │   │   └── service/
│   │   │       └── objectbox_store_holder.dart
│   │   ├── domain/
│   │   │   ├── entity/
│   │   │   │   ├── dictionary.dart       # Dictionary enum
│   │   │   │   ├── search_word.dart     # SearchWord interface
│   │   │   │   └── word.dart            # Word entity
│   │   │   ├── repository/
│   │   │   │   ├── analytics_app_repository.dart
│   │   │   │   └── database_repository.dart
│   │   │   └── use_case/
│   │   │       ├── get_app_link_stream.dart
│   │   │       ├── handle_app_link.dart
│   │   │       ├── init_database.dart
│   │   │       ├── init_remote_config.dart
│   │   │       └── log_analytics_app_started.dart
│   │   └── presentation/
│   │       ├── skarnik_app.dart         # Main app widget
│   │       ├── skarnik_app_bloc.dart    # App BLoC
│   │       └── skarnik_router.dart      # GoRouter config
│   │
│   ├── home/                     # Home/History tab
│   │   ├── domain/
│   │   │   └── use_case/
│   │   │       └── load_history.dart
│   │   └── presentation/
│   │       ├── home_cubit.dart
│   │       └── home_page.dart
│   │
│   ├── search/                   # Search feature
│   │   ├── data/
│   │   │   └── repository/
│   │   │       ├── objectbox_search_repository.dart
│   │   │       └── query_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repository/
│   │   │   │   ├── query_repository.dart
│   │   │   │   └── search_repository.dart
│   │   │   └── use_case/
│   │   │       └── search_use_case.dart
│   │   └── presentation/
│   │       ├── search_cubit.dart
│   │       ├── search_page.dart
│   │       └── widgets/
│   │
│   ├── translation/              # Translation detail
│   │   ├── data/
│   │   │   ├── http/
│   │   │   │   └── skarnik_dio.dart
│   │   │   ├── model/
│   │   │   │   ├── api_word_model.dart
│   │   │   │   └── api_word_model.g.dart
│   │   │   └── repository/
│   │   │       ├── api_translation_repository_impl.dart
│   │   │       ├── dev_analytics_translation_repository.dart
│   │   │       ├── firebase_analytics_translation_repository.dart
│   │   │       ├── objectbox_favorites_repository.dart
│   │   │       ├── objectbox_history_repository.dart
│   │   │       ├── objectbox_word_repository.dart
│   │   │       └── skarnik_translation_repository.dart
│   │   ├── domain/
│   │   │   ├── entity/
│   │   │   │   ├── api_word.dart
│   │   │   │   └── translation.dart
│   │   │   ├── repository/
│   │   │   │   ├── analytics_translation_repository.dart
│   │   │   │   ├── api_translation_repository.dart
│   │   │   │   ├── favorites_repository.dart
│   │   │   │   ├── history_repository.dart
│   │   │   │   ├── translation_repository.dart
│   │   │   │   └── word_repository.dart
│   │   │   └── use_case/
│   │   │       ├── add_to_favorites.dart
│   │   │       ├── check_in_favorites.dart
│   │   │       ├── get_translation.dart
│   │   │       ├── get_word.dart
│   │   │       ├── log_analytics_add_to_favorites.dart
│   │   │       ├── log_analytics_share.dart
│   │   │       ├── log_analytics_translation.dart
│   │   │       ├── remove_from_favorites.dart
│   │   │       └── save_to_history.dart
│   │   └── presentation/
│   │       ├── translation_cubit.dart
│   │       ├── translation_page.dart
│   │       └── widgets/
│   │           ├── action_favorites.dart
│   │           ├── action_share.dart
│   │           └── translation_html.dart
│   │
│   ├── favorites/                # Bookmarks feature
│   │   ├── domain/
│   │   │   └── use_case/
│   │   │       └── load_favorites.dart
│   │   └── presentation/
│   │       ├── favorites_cubit.dart
│   │       ├── favorites_page.dart
│   │       └── widgets/
│   │           └── favorites_list_view.dart
│   │
│   ├── history/                  # Search history
│   │   └── presentation/
│   │       ├── history_cubit.dart
│   │       ├── history_page.dart
│   │       └── widgets/
│   │           └── history_list_view.dart
│   │
│   ├── vocabulary/              # Dictionary browse
│   │   ├── data/
│   │   │   └── repository/
│   │   │       ├── dev_analytics_vocabulary_repository.dart
│   │   │       ├── firebase_analytics_vocabulary_repository.dart
│   │   │       └── vocabulary_repository.dart (impl)
│   │   ├── domain/
│   │   │   ├── repository/
│   │   │   │   ├── analytics_vocabulary_repository.dart
│   │   │   │   └── vocabulary_repository.dart (interface)
│   │   │   └── use_case/
│   │   │       ├── load_vocabulary.dart
│   │   │       └── log_analytics_vocabulary_word.dart
│   │   └── presentation/
│   │       ├── vocabulary_cubit.dart
│   │       ├── vocabulary_page.dart
│   │       └── widgets/
│   │           ├── alphabet_list_view.dart
│   │           └── vocabulary_num_page.dart
│   │
│   └── settings/                # App settings
│       ├── data/
│       │   └── repository/
│       │       └── objectbox_settings_history_repository.dart
│       ├── domain/
│       │   ├── repository/
│       │   │   └── settings_history_repository.dart
│       │   └── use_case/
│       │       └── clear_history.dart
│       └── presentation/
│           ├── settings_cubit.dart
│           ├── settings_page.dart
│           └── widgets/
│               └── about_bottom_sheet.dart
│
└── widgets/
    └── adaptive_icons.dart       # Platform-adaptive icons
```

---

## Generated Files (do not edit manually)

- `lib/di.skarnik.config.dart` - Generated by injectable_generator
- `lib/objectbox.g.dart` - Generated by objectbox_generator
- `lib/serializers.g.dart` - Generated by built_value_generator
- `lib/features/translation/data/model/api_word_model.g.dart` - Generated by built_value_generator
