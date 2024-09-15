import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/history/presentation/history_cubit.dart';
import 'package:skarnik_flutter/strings.dart';

import '../domain/use_case/clear_history.dart';
import 'settings_cubit.dart';
import 'widgets/about_bottom_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (context) => SettingsCubit(
        clearHistoryUseCase: getIt<ClearHistoryUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.preferences),
        ),
        body: BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsClearedState) {
              context.read<HistoryCubit>().reload();
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(Strings.historyCleared),
                  ),
                );
            }
          },
          child: Builder(
            builder: (context) {
              final cubit = context.read<SettingsCubit>();
              return ListView(
                children: [
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, state) {
                      final enabled = state is! SettingsInProgressState;
                      return ListTile(
                        title: const Text(Strings.clearHistory),
                        onTap: () => _showClearHistoryConfirmation(context),
                        enabled: enabled,
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(Strings.writeToDevs),
                    onTap: cubit.mailToDevs,
                  ),
                  ListTile(
                    title: const Text(Strings.aboutSkarnik),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      showDragHandle: true,
                      isScrollControlled: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      builder: (context) => BlocProvider.value(
                        value: cubit,
                        child: const AboutBottomSheet(),
                      ),
                    ),
                  ),
                  FutureBuilder<String>(
                    future: cubit.getAppNameAndVersion(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data;
                        if (data != null) {
                          return ListTile(
                            subtitle: Text(data),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showClearHistoryConfirmation(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final result = await showOkCancelAlertDialog(
      context: context,
      title: Strings.attention,
      message: Strings.clearHistoryConfirmation,
      cancelLabel: Strings.no,
      okLabel: Strings.yes,
    );
    if (result == OkCancelResult.ok) {
      await cubit.clearHistory();
    }
  }
}
