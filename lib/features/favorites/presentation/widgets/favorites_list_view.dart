import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../favorites_cubit.dart';

class FavoritesListView extends StatelessWidget {
  const FavoritesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Word>(
      pagingController: context.read<FavoritesCubit>().pagingController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      builderDelegate: PagedChildBuilderDelegate<Word>(
        noItemsFoundIndicatorBuilder: (_) => const Center(
          child: Text(
            'Пакуль ў закладках няма ніводнага слова',
            textAlign: TextAlign.center,
          ),
        ),
        itemBuilder: (context, word, index) {
          return Dismissible(
            key: Key('word_${word.wordId}'),
            onDismissed: (_) => context.read<FavoritesCubit>().removeFromFavorites(word),
            direction: DismissDirection.endToStart,
            background: ColoredBox(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Icon(
                    Icons.delete_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            child: ListTile(
              title: Text(word.word),
              subtitle: Text(
                word.dictionary.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () => context.go(
                '/translate/word',
                extra: {
                  'word': word,
                  // Не захоўваць у гісторыю, таму што слова ўжо захавана ў Гісторыі.
                  'save_to_history': false,
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
