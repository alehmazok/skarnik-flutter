import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/presentation/translation_page.dart';
import 'package:skarnik_flutter/strings.dart';
import 'package:skarnik_flutter/widgets/breakpoints.dart';
import 'package:skarnik_flutter/widgets/master_detail_view.dart';

import '../domain/use_case/load_vocabulary.dart';
import '../domain/use_case/log_analytics_vocabulary_word.dart';
import 'vocabulary_cubit.dart';
import 'widgets/vocabulary_num_page.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> with SingleTickerProviderStateMixin {
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
      context.push('/translate/word', extra: {'word': word, 'save_to_history': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VocabularyCubit(
        loadVocabularyUseCase: getIt<LoadVocabularyUseCase>(),
        logAnalyticsVocabularyWordUseCase: getIt<LogAnalyticsVocabularyWordUseCase>(),
        tickerProvider: this,
      )..loadWords(langIdTsbm),
      child: Builder(
        builder: (context) {
          final cubit = context.read<VocabularyCubit>();
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              bottom: TabBar(
                controller: cubit.tabController,
                tabs: const [
                  Tab(text: Strings.dictTsbm),
                  Tab(text: Strings.dictBelRus),
                  Tab(text: Strings.dictRusBel),
                ],
              ),
            ),
            body: ValueListenableBuilder<Word?>(
              valueListenable: _selectedWord,
              builder: (context, selectedWord, _) => MasterDetailView(
                list: TabBarView(
                  controller: cubit.tabController,
                  children: VocabularyCubit.langIdList
                      .map(
                        (it) => VocabularyNumPage(
                          langId: it,
                          onWordTap: (word) => _onWordTap(context, word),
                        ),
                      )
                      .toList(),
                ),
                detail: selectedWord == null
                    ? null
                    : KeyedSubtree(
                        key: ValueKey('${selectedWord.langId}_${selectedWord.wordId}'),
                        child: TranslationPage.word(word: selectedWord, saveToHistory: true),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
