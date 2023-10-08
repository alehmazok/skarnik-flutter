import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../translation_cubit.dart';

class ActionShare extends StatelessWidget {
  const ActionShare({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      buildWhen: (_, current) => current is TranslationLoadedState,
      builder: (context, state) {
        if (state is TranslationLoadedState) {
          return IconButton(
            onPressed: () => context.read<TranslationCubit>().share(state.translation),
            icon: const Icon(Icons.share),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
