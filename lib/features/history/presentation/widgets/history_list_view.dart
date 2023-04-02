import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/history/presentation/history_cubit.dart';

class HistoryListView extends StatelessWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Word>(
      pagingController: context.read<HistoryCubit>().pagingController,
      builderDelegate: PagedChildBuilderDelegate<Word>(
        itemBuilder: (context, word, index) {
          return ListTile(
            title: Text(word.word),
            subtitle: Text(word.dictName),
            onTap: () => context.go(
              '/translate/word',
              extra: {
                'word': word,
                // Не захоўваць у гісторыю, таму што пераход быў зроблены ўласна з экрана Гісторыі.
                'save_to_history': false,
              },
            ),
          );
        },
      ),
    );
  }
}
