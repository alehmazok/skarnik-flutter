import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../history_cubit.dart';

class HistoryListView extends StatelessWidget {
  final void Function(Word word) onWordTap;

  const HistoryListView({super.key, required this.onWordTap});

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Word>(
      pagingController: context.read<HistoryCubit>().pagingController,
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
              word.dictionary.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () => onWordTap(word),
          );
        },
      ),
    );
  }
}
