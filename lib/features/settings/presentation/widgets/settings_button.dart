import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/history/presentation/history_cubit.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';

import '../offline_dictionaries_promo_cubit.dart';

/// Opens Settings, passing along the ambient [HistoryCubit] so history
/// refreshes after a "clear history" action. Used both from [HistoryPage]'s
/// AppBar (phone) and [HomeShell]'s NavigationRail (tablet).
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.read<HistoryCubit>();
    return IconButton(
      onPressed: () => context.push('/settings', extra: historyCubit),
      icon: BlocBuilder<OfflineDictionariesPromoCubit, bool>(
        bloc: getIt<OfflineDictionariesPromoCubit>(),
        builder: (context, showBadge) {
          return Badge(
            isLabelVisible: showBadge,
            child: Icon(AdaptiveIcons.settings),
          );
        },
      ),
    );
  }
}
