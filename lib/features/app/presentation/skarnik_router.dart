import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/favorites/presentation/favorites_page.dart';
import 'package:skarnik_flutter/features/history/presentation/history_cubit.dart';
import 'package:skarnik_flutter/features/history/presentation/history_page.dart';
import 'package:skarnik_flutter/features/home/presentation/home_shell.dart';
import 'package:skarnik_flutter/features/search/presentation/search_page.dart';
import 'package:skarnik_flutter/features/settings/presentation/settings_page.dart';
import 'package:skarnik_flutter/features/stress/domain/entity/stress_source.dart';
import 'package:skarnik_flutter/features/stress/presentation/stress_page.dart';
import 'package:skarnik_flutter/features/stress/presentation/stress_table_page.dart';
import 'package:skarnik_flutter/features/translation/presentation/translation_page.dart';
import 'package:skarnik_flutter/features/vocabulary/presentation/vocabulary_page.dart';

abstract class SkarnikRouter {
  static final goRouter = GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vocabulary',
                builder: (context, state) => const VocabularyPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => BlocProvider.value(
          value: state.extra as HistoryCubit,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/translate/:langId/:wordId',
        builder: (context, state) {
          final langId = int.parse(state.pathParameters['langId'] ?? '');
          final wordId = int.parse(state.pathParameters['wordId'] ?? '');
          return TranslationPage(
            key: Key('$langId/$wordId'),
            langId: langId,
            wordId: wordId,
          );
        },
      ),
      GoRoute(
        path: '/translate/word',
        builder: (context, state) {
          final arguments = state.extra as Map<String, dynamic>;
          return TranslationPage.word(
            word: arguments['word'] as Word,
            saveToHistory: arguments['save_to_history'] as bool,
          );
        },
      ),
      GoRoute(
        path: '/stress',
        builder: (context, state) {
          final word = state.extra as String;
          return StressPage(word: word);
        },
        routes: [
          GoRoute(
            path: 'table',
            builder: (context, state) {
              final (wordId, source) = state.extra as (int, StressSource);
              return StressTablePage(wordId: wordId, source: source);
            },
          ),
        ],
      ),
    ],
    initialLocation: '/history',
  );
}
