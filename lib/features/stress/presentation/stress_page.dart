import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/strings.dart';

import '../domain/use_case/log_analytics_stress.dart';
import '../domain/use_case/resolve_stress_word_list.dart';
import 'stress_cubit.dart';

class StressPage extends StatelessWidget {
  final String word;
  final LogAnalyticsStressUseCase logAnalyticsStressUseCase;
  final ResolveStressWordListUseCase resolveStressWordListUseCase;

  StressPage({
    super.key,
    required this.word,
    LogAnalyticsStressUseCase? logAnalyticsStressUseCase,
    ResolveStressWordListUseCase? resolveStressWordListUseCase,
  }) : logAnalyticsStressUseCase = logAnalyticsStressUseCase ?? getIt<LogAnalyticsStressUseCase>(),
       resolveStressWordListUseCase =
           resolveStressWordListUseCase ?? getIt<ResolveStressWordListUseCase>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StressCubit>(
      create: (_) => StressCubit(
        word: word,
        logAnalyticsStressUseCase: logAnalyticsStressUseCase,
        resolveStressWordListUseCase: resolveStressWordListUseCase,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text(Strings.nacisk)),
        body: BlocConsumer<StressCubit, StressState>(
          listener: (context, state) {
            if (state is StressNotFoundState) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(const SnackBar(content: Text(Strings.naciskNotFound)));
              context.pop();
            } else if (state is StressWordSelectedState) {
              final extra = (state.wordId, state.source);
              if (state.replace) {
                context.replace('/stress/table', extra: extra);
              } else {
                context.push('/stress/table', extra: extra);
              }
            }
          },
          buildWhen: (_, current) =>
              current is StressInProgressState ||
              current is StressWordSelectionState ||
              current is StressFailedState,
          builder: (context, state) {
            if (state is StressWordSelectionState) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      Strings.naciskSelectWord,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  for (final entry in state.words)
                    ListTile(
                      title: Text(entry.word),
                      subtitle: entry.tableName != null
                          ? Text(Strings.partOfSpeech[entry.tableName!] ?? entry.tableName!)
                          : null,
                      onTap: () => context.read<StressCubit>().selectWord(entry),
                    ),
                ],
              );
            }
            if (state is StressFailedState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    Strings.naciskError,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
