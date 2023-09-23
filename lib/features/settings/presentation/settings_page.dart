import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';

import '../domain/use_case/clear_history.dart';
import 'settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (context) => SettingsCubit(
        clearHistoryUseCase: getIt<ClearHistoryUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Наладкі'),
        ),
        body: BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsClearedState) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Гісторыя паспяхова ачышчана.'),
                  ),
                );
            }
          },
          child: ListView(
            children: [
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final enabled = state is! SettingsInProgressState;
                  return ListTile(
                    title: const Text('Ачысціць гісторыю пошуку'),
                    onTap: () => _showClearHistoryConfirmation(context),
                    enabled: enabled,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClearHistoryConfirmation(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final result = await showOkCancelAlertDialog(
      context: context,
      title: 'Увага',
      message: 'Вы сапраўды жадаеце ачысціць гісторыю пошука?',
      cancelLabel: 'Не',
      okLabel: 'Так',
    );
    if (result == OkCancelResult.ok) {
      await cubit.clearHistory();
    }
  }
}
