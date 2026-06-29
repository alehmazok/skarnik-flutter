import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/strings.dart';

import '../domain/use_case/get_stress_table.dart';
import 'stress_cubit.dart';
import 'widgets/stress_table.dart';

class StressTablePage extends StatelessWidget {
  final int wordId;
  final GetStressTableUseCase getStressTableUseCase;

  StressTablePage({
    super.key,
    required this.wordId,
    GetStressTableUseCase? getStressTableUseCase,
  }) : getStressTableUseCase = getStressTableUseCase ?? getIt<GetStressTableUseCase>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StressTableCubit>(
      create: (_) => StressTableCubit(getStressTableUseCase: getStressTableUseCase)..load(wordId),
      child: Scaffold(
        appBar: AppBar(title: const Text(Strings.nacisk)),
        body: BlocConsumer<StressTableCubit, StressState>(
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
