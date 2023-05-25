import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';

import '../domain/use_case/load_vocabulary.dart';
import '../domain/use_case/stream_vocabulary.dart';
import 'vocabulary_cubit.dart';
import 'widgets/vocabulary_page.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({Key? key}) : super(key: key);

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VocabularyCubit(
        loadVocabularyUseCase: getIt<LoadVocabularyUseCase>(),
        streamVocabularyUseCase: getIt<StreamVocabularyUseCase>(),
        tickerProvider: this,
      ),
      child: Builder(
        builder: (context) {
          final cubit = context.read<VocabularyCubit>();
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              bottom: TabBar(
                controller: cubit.tabController,
                tabs: const [
                  Tab(text: 'Рус-Бел'),
                  Tab(text: 'Бел-Рус'),
                  Tab(text: 'Тлумачальны'),
                ],
                // onTap: (index) => cubit.pageController.animateToPage(
                //   index,
                //   duration: const Duration(milliseconds: 250),
                //   curve: Curves.linear,
                // ),
              ),
            ),
            body: TabBarView(
              controller: cubit.tabController,
              children: const [
                VocabularyNumPage(langId: 0),
                VocabularyNumPage(langId: 1),
                VocabularyNumPage(langId: 2),
              ],
            ),
            // body: BlocBuilder<VocabularyCubit, VocabularyState>(
            //   builder: (context, state) {
            //     if (state is VocabularyLoadedState) {
            //       return AlphabetListView(
            //         langId: state.langId,
            //         words: state.words,
            //       );
            //     }
            //     return const Center(child: CircularProgressIndicator());
            //   },
            // ),
          );
        },
      ),
    );
  }
}
