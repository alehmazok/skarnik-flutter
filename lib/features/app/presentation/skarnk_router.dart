import 'package:go_router/go_router.dart';

import '../../history/presentation/history_page.dart';
import '../../search/presentation/search_page.dart';
import '../../translation/presentation/translation_page.dart';
import '../domain/entity/word.dart';

abstract class SkarnikRouter {
  static final goRouter = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HistoryPage(),
        routes: [
          GoRoute(
            path: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: 'translate/:langId/:wordId',
            builder: (context, state) => TranslationPage(
              langId: int.parse(state.params['langId'] ?? ''),
              wordId: int.parse(state.params['wordId'] ?? ''),
            ),
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
