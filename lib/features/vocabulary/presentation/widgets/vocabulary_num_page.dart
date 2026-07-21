import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../vocabulary_cubit.dart';
import 'alphabet_list_view.dart';

class VocabularyNumPage extends StatelessWidget {
  final int langId;
  final void Function(Word word) onWordTap;

  const VocabularyNumPage({
    super.key,
    required this.langId,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyCubit, VocabularyState>(
      buildWhen: (_, current) => current is VocabularyLoadedState && current.langId == langId,
      builder: (context, state) {
        if (state is VocabularyLoadedState) {
          return SimpleListView(
            langId: state.langId,
            words: state.words.toList(),
            onWordTap: onWordTap,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
