import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/features/history/presentation/history_cubit.dart';

import '../../home/presentation/home_page.dart';
import '../../search/presentation/search_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../translation/presentation/translation_page.dart';
import '../domain/entity/word.dart';

abstract class SkarnikRouter {
  static final goRouter = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => BlocProvider.value(
              value: state.extra as HistoryCubit,
              child: const SettingsPage(),
            ),
          ),
          GoRoute(
            path: 'translate/:langId/:wordId',
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
            path: 'translate/word',
            builder: (context, state) {
              final arguments = state.extra as Map<String, dynamic>;
              return TranslationPage.word(
                word: arguments['word'] as Word,
                saveToHistory: arguments['save_to_history'] as bool,
              );
            },
          ),
        ],
      ),
    ],
    initialLocation: '/',
  );
}
