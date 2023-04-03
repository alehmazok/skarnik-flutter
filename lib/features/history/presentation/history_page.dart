import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_bloc.dart';

import '../domain/use_case/load_history.dart';
import 'history_cubit.dart';
import 'widgets/history_list_view.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: SizedBox(
          width: double.infinity,
          height: 56,
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(56),
            ),
            onTap: () => context.go('/search'),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(56),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.search, size: 24),
                  ),
                  Text(
                    'Пошук слоў',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
/*
          child: TextField(
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Пошук слоў',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(56),
                ),
              ),
            ),
            readOnly: true,
            onTap: () => context.go('/search'),
          ),
*/
        ),
      ),
      body: BlocBuilder<SkarnikAppBloc, SkarnikAppState>(
        buildWhen: (_, current) => current is SkarnikAppInitedState,
        builder: (context, appState) {
          if (appState is SkarnikAppInitedState) {
            return BlocProvider<HistoryCubit>(
              create: (context) => HistoryCubit(
                loadHistoryUseCase: getIt<LoadHistoryUseCase>(),
              ),
              child: BlocListener<SkarnikAppBloc, SkarnikAppState>(
                listener: (context, state) {
                  if (state is SkarnikAppHistoryUpdatedState) {
                    context.read<HistoryCubit>().reload();
                  }
                  if (state is SkarnikAppAppLinkReceivedState) {
                    context.go('/translate/${state.langId}/${state.wordId}');
                  }
                },
                child: const HistoryListView(),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
