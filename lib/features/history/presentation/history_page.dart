import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/settings/presentation/widgets/settings_button.dart';
import 'package:skarnik_flutter/features/translation/presentation/translation_page.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';
import 'package:skarnik_flutter/widgets/breakpoints.dart';
import 'package:skarnik_flutter/widgets/master_detail_view.dart';

import '../../app/presentation/skarnik_app_bloc.dart';
import 'history_cubit.dart';
import 'widgets/history_list_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
          // Не захоўваць у гісторыю, таму што пераход быў зроблены ўласна з экрана Гісторыі.
          'save_to_history': false,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // На rail-макеце кнопка налад пераносіцца ў NavigationRail (гл. HomeShell).
    final isRail = MediaQuery.sizeOf(context).width >= Breakpoints.rail;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: SizedBox(
          width: double.infinity,
          height: 56,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(56),
            ),
            onTap: () => context.push('/search'),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(56),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(AdaptiveIcons.search, size: 24),
                  ),
                  Text(
                    'Пошук слоў',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (!isRail) const SettingsButton(),
        ],
      ),
      body: BlocListener<SkarnikAppBloc, SkarnikAppState>(
        listener: (context, state) {
          if (state is SkarnikAppHistoryUpdatedState) {
            context.read<HistoryCubit>().reload();
          }
          if (state is SkarnikAppAppLinkReceivedState) {
            context.push('/translate/${state.langId}/${state.wordId}');
          }
        },
        child: ValueListenableBuilder<Word?>(
          valueListenable: _selectedWord,
          builder: (context, selectedWord, _) => MasterDetailView(
            list: HistoryListView(onWordTap: (word) => _onWordTap(context, word)),
            detail: selectedWord == null
                ? null
                : KeyedSubtree(
                    key: ValueKey('${selectedWord.langId}_${selectedWord.wordId}'),
                    child: TranslationPage.word(word: selectedWord, saveToHistory: false),
                  ),
          ),
        ),
      ),
    );
  }
}
