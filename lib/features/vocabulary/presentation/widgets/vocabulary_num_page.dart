import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../vocabulary_cubit.dart';
import 'alphabet_list_view.dart';

class VocabularyNumPage extends StatelessWidget {
  final int langId;

  const VocabularyNumPage({
    Key? key,
    required this.langId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyCubit, VocabularyState>(
      buildWhen: (_, current) => current is VocabularyLoadedState && current.langId == langId,
      builder: (context, state) {
        if (state is VocabularyLoadedState) {
          return SimpleListView(
            langId: state.langId,
            words: state.words.toList(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
