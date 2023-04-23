import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';

import '../domain/use_case/load_vocabulary.dart';
import '../domain/use_case/stream_vocabulary.dart';
import 'vocabulary_cubit.dart';
import 'widgets/alphabet_list_view.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VocabularyCubit(
        loadVocabularyUseCase: getIt<LoadVocabularyUseCase>(),
        streamVocabularyUseCase: getIt<StreamVocabularyUseCase>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (context) {
            final cubit = context.read<VocabularyCubit>();
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                bottom: TabBar(
                  tabs: const [
                    Tab(text: 'Рус-Бел'),
                    Tab(text: 'Бел-Рус'),
                    Tab(text: 'Тлумачальны'),
                  ],
                  onTap: (index) => cubit.streamWords(index),
                ),
              ),
              body: BlocBuilder<VocabularyCubit, VocabularyState>(
                builder: (context, state) {
                  if (state is VocabularyLoadedState) {
                    return AlphabetListView(
                      langId: state.langId,
                      words: state.words,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
