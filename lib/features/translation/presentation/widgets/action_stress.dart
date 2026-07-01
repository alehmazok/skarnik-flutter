import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/strings.dart';

import '../translation_cubit.dart';

class ActionStress extends StatelessWidget {
  const ActionStress({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      buildWhen: (_, current) => current is TranslationLoadedState,
      builder: (context, state) {
        if (state is! TranslationLoadedState) return const SizedBox.shrink();
        final candidates = state.translation.stressCandidates;
        if (candidates.isEmpty) return const SizedBox.shrink();
        if (candidates.length == 1) {
          return TextButton(
            onPressed: () => _navigateToStress(context, candidates.first),
            child: const Text(Strings.nacisk),
          );
        }
        return MenuAnchor(
          builder: (context, controller, _) => TextButton(
            onPressed: () => controller.open(),
            child: const Text(Strings.nacisk),
          ),
          menuChildren: [
            for (final candidate in candidates)
              MenuItemButton(
                style: MenuItemButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                onPressed: () => _navigateToStress(context, candidate),
                child: Text(candidate),
              ),
          ],
        );
      },
    );
  }

  static void _navigateToStress(BuildContext context, String word) {
    context.push('/stress', extra: word);
  }
}
