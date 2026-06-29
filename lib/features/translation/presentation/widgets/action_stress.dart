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
        return TextButton(
          onPressed: () => _onStressPressed(context, candidates),
          child: const Text(Strings.nacisk),
        );
      },
    );
  }

  static void _onStressPressed(BuildContext context, List<String> candidates) {
    if (candidates.length == 1) {
      _navigateToStress(context, candidates.first);
    } else {
      showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => ListView(
          shrinkWrap: true,
          children: [
            for (final candidate in candidates)
              ListTile(
                title: Text(candidate),
                onTap: () => Navigator.of(ctx).pop(candidate),
              ),
          ],
        ),
      ).then((selected) {
        if (selected != null && context.mounted) {
          _navigateToStress(context, selected);
        }
      });
    }
  }

  static void _navigateToStress(BuildContext context, String word) {
    context.push('/stress', extra: word);
  }
}
