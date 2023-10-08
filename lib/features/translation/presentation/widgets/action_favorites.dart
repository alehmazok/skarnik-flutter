import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../translation_cubit.dart';

class ActionFavorites extends StatelessWidget {
  const ActionFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) {
        if (state is TranslationInFavoritesState) {
          final cubit = context.read<TranslationCubit>();
          return IconButton(
            onPressed: () {
              state.inFavorites ? cubit.removeFromFavorites(state.word) : cubit.addToFavorites(state.word);
            },
            icon: state.inFavorites
                ? Icon(
                    Icons.bookmark_added_rounded,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  )
                : const Icon(
                    Icons.bookmark_add_outlined,
                  ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
