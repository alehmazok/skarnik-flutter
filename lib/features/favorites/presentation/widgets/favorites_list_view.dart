import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../favorites_cubit.dart';

class FavoritesListView extends StatelessWidget {
  const FavoritesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Word>(
      pagingController: context.read<FavoritesCubit>().pagingController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      builderDelegate: PagedChildBuilderDelegate<Word>(
        noItemsFoundIndicatorBuilder: (_) => const Center(
          child: Text(
            'Пачніце ўводзіць слова ў пошук...',
            textAlign: TextAlign.center,
          ),
        ),
        itemBuilder: (context, word, index) {
          return ListTile(
            title: Text(word.word),
            subtitle: Text(
              word.dictName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () => context.go(
              '/translate/word',
              extra: {
                'word': word,
                // Не захоўваць у гісторыю, таму што пераход быў зроблены ўласна з экрана Гісторыі.
                'save_to_favorites': false,
              },
            ),
          );
        },
      ),
    );
  }
}
