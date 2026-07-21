import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/favorites/domain/entity/favorites_sort_order.dart';
import 'package:skarnik_flutter/features/favorites/domain/repository/favorites_sort_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart';
import 'package:skarnik_flutter/features/translation/presentation/translation_page.dart';
import 'package:skarnik_flutter/strings.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';
import 'package:skarnik_flutter/widgets/breakpoints.dart';
import 'package:skarnik_flutter/widgets/master_detail_view.dart';

import '../domain/use_case/load_favorites.dart';
import 'favorites_cubit.dart';
import 'widgets/favorites_list_view.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _selectedWord = ValueNotifier<Word?>(null);

  @override
  void dispose() {
    _selectedWord.dispose();
    super.dispose();
  }

  void _onWordTap(BuildContext context, Word word) {
    if (MediaQuery.sizeOf(context).width >= Breakpoints.masterDetail) {
      _selectedWord.value = word;
    } else {
      context.push(
        '/translate/word',
        extra: {
          'word': word,
          // Не захоўваць у гісторыю, таму што слова ўжо захавана ў Гісторыі.
          'save_to_history': false,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesCubit(
        loadFavoritesUseCase: getIt<LoadFavoritesUseCase>(),
        removeFromFavoritesUseCase: getIt<RemoveFromFavoritesUseCase>(),
        favoritesSortRepository: getIt<FavoritesSortRepository>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.bookmarks),
          actions: [
            Builder(
              builder: (context) {
                final cubit = context.read<FavoritesCubit>();
                return ValueListenableBuilder<FavoritesSortOrder>(
                  valueListenable: cubit.sortOrder,
                  builder: (context, sortOrder, _) => PopupMenuButton<FavoritesSortOrder>(
                    icon: Icon(AdaptiveIcons.sortBy),
                    initialValue: sortOrder,
                    onSelected: cubit.changeSortOrder,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: FavoritesSortOrder.dateAdded,
                        child: Text(Strings.sortByDateAdded),
                      ),
                      const PopupMenuItem(
                        value: FavoritesSortOrder.alphabetical,
                        child: Text(Strings.sortByLetter),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocListener<FavoritesCubit, FavoritesState>(
          listener: (context, state) {
            if (state is FavoritesRemovedState) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: const Text(Strings.removedFromBookmarks),
                    action: SnackBarAction(
                      label: Strings.revert,
                      onPressed: () => context.read<FavoritesCubit>().cancelRemoval(state.word),
                    ),
                  ),
                );
            }
          },
          child: ValueListenableBuilder<Word?>(
            valueListenable: _selectedWord,
            builder: (context, selectedWord, _) => MasterDetailView(
              list: FavoritesListView(onWordTap: (word) => _onWordTap(context, word)),
              detail: selectedWord == null
                  ? null
                  : KeyedSubtree(
                      key: ValueKey('${selectedWord.langId}_${selectedWord.wordId}'),
                      child: TranslationPage.word(word: selectedWord, saveToHistory: false),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
