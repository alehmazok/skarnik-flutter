import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_cubit.dart';

import '../domain/use_case/load_history.dart';
import 'history_cubit.dart';
import 'widgets/history_list_view.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     onPressed: () => context.go('/search'),
        //     icon: const Icon(Icons.search),
        //   ),
        // ],
        // backgroundColor: Colors.grey.shade50,
        // elevation: 0,
        title: SizedBox(
          height: 56,
          child: TextField(
            autofocus: false,
            decoration: const InputDecoration(
              hintText: 'Пошук слоў',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(56),
                ),
              ),
            ),
            readOnly: true,
            onTap: () => context.go('/search'),
          ),
        ),
      ),
      body: BlocBuilder<SkarnikAppCubit, SkarnikAppState>(
        buildWhen: (_, current) => current is SkarnikAppInitedState,
        builder: (context, appState) {
          if (appState is SkarnikAppInitedState) {
            return BlocProvider<HistoryCubit>(
              create: (context) => HistoryCubit(
                loadHistoryUseCase: getIt<LoadHistoryUseCase>(),
              ),
              child: BlocListener<SkarnikAppCubit, SkarnikAppState>(
                listener: (context, state) {
                  if (state is SkarnikAppHistoryUpdatedState) {
                    context.read<HistoryCubit>().reload();
                  }
                },
                child: const HistoryListView(),
              ),
/*
              child: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, state) {
                  if (state is HistoryLoadedState) {
                    return HistoryListView(words: state.words);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
*/
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
