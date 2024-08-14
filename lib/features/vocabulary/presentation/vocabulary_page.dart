import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

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
                  Tab(text: 'Тлумачальны'),
                  Tab(text: 'Бел-Рус'),
                  Tab(text: 'Рус-Бел'),
                ],
              ),
            ),
            body: TabBarView(
              controller: cubit.tabController,
              children: VocabularyCubit.langIdList
                  .map(
                    (it) => VocabularyNumPage(langId: it),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
