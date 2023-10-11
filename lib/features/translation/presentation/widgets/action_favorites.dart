import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';

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
                    AdaptiveIcons.bookmarkAdded,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  )
                : Icon(AdaptiveIcons.bookmarkAdd),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
