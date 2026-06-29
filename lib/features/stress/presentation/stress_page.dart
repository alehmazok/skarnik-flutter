import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/strings.dart';

import '../domain/use_case/get_stress_table.dart';
import '../domain/use_case/log_analytics_stress.dart';
import 'stress_cubit.dart';
import 'widgets/stress_table.dart';

class StressPage extends StatelessWidget {
  final String word;
  final GetStressTableUseCase getStressTableUseCase;
  final LogAnalyticsStressUseCase logAnalyticsStressUseCase;

  StressPage({
    super.key,
    required this.word,
    GetStressTableUseCase? getStressTableUseCase,
    LogAnalyticsStressUseCase? logAnalyticsStressUseCase,
  }) : getStressTableUseCase = getStressTableUseCase ?? getIt<GetStressTableUseCase>(),
       logAnalyticsStressUseCase = logAnalyticsStressUseCase ?? getIt<LogAnalyticsStressUseCase>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StressCubit>(
      create: (_) => StressCubit(
        word: word,
        getStressTableUseCase: getStressTableUseCase,
        logAnalyticsStressUseCase: logAnalyticsStressUseCase,
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
            }
          },
          buildWhen: (_, current) =>
              current is StressInProgressState ||
              current is StressLoadedState ||
              current is StressFailedState,
          builder: (context, state) {
            if (state is StressLoadedState) {
              return StressTable(rows: state.rows);
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
