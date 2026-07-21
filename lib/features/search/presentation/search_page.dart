import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/presentation/translation_page.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';
import 'package:skarnik_flutter/widgets/breakpoints.dart';
import 'package:skarnik_flutter/widgets/master_detail_view.dart';

import '../domain/use_case/log_analytics_search_no_results.dart';
import '../domain/use_case/log_analytics_search_performed.dart';
import '../domain/use_case/log_analytics_search_result_tapped.dart';
import '../domain/use_case/search_use_case.dart';
import 'search_cubit.dart';
import 'widgets/search_extra_buttons.dart';
import 'widgets/search_list_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
          'save_to_history': true,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>(
      create: (context) => SearchCubit(
        keyboardVisibilityController: KeyboardVisibilityController(),
        searchUseCase: getIt<SearchUseCase>(),
        logAnalyticsSearchPerformedUseCase: getIt<LogAnalyticsSearchPerformedUseCase>(),
        logAnalyticsSearchNoResultsUseCase: getIt<LogAnalyticsSearchNoResultsUseCase>(),
        logAnalyticsSearchResultTappedUseCase: getIt<LogAnalyticsSearchResultTappedUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: SizedBox(
            height: 56,
            child: Builder(
              builder: (context) {
                final cubit = context.read<SearchCubit>();
                return TextField(
                  controller: cubit.searchTextController,
                  autofocus: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Пошук слоў',
                    border: InputBorder.none,
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => cubit.clearSearch(),
                          icon: Icon(AdaptiveIcons.close),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        body: ValueListenableBuilder<Word?>(
          valueListenable: _selectedWord,
          builder: (context, selectedWord, _) => MasterDetailView(
            list: BlocBuilder<SearchCubit, SearchState>(
              buildWhen: (_, current) => current is SearchLoadedState,
              builder: (context, state) {
                if (state is SearchLoadedState) {
                  return SearchListView(
                    isNothingFound: state.isNothingFound,
                    words: state.items,
                    query: state.query,
                    onWordTap: (word) => _onWordTap(context, word),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            detail: selectedWord == null
                ? null
                : KeyedSubtree(
                    key: ValueKey('${selectedWord.langId}_${selectedWord.wordId}'),
                    child: TranslationPage.word(word: selectedWord, saveToHistory: true),
                  ),
          ),
        ),
        floatingActionButton: BlocBuilder<SearchCubit, SearchState>(
          buildWhen: (_, current) => current is SearchKeyboardChangedState,
          builder: (context, state) {
            if (state is SearchKeyboardChangedState && state.isVisible) {
              return const SearchExtraButtons();
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
