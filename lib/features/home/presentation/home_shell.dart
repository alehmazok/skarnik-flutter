import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/history/presentation/history_cubit.dart';
import 'package:skarnik_flutter/features/home/domain/use_case/load_history.dart';
import 'package:skarnik_flutter/features/settings/presentation/widgets/settings_button.dart';
import 'package:skarnik_flutter/strings.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';
import 'package:skarnik_flutter/widgets/breakpoints.dart';

import '../../app/presentation/skarnik_app_bloc.dart';

class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  static final _destinations = [
    (icon: AdaptiveIcons.search, label: Strings.search),
    (icon: AdaptiveIcons.bookmark, label: Strings.bookmarks),
    (icon: AdaptiveIcons.book, label: Strings.dictionary),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkarnikAppBloc, SkarnikAppState>(
      buildWhen: (_, current) => current is SkarnikAppInitedState,
      builder: (context, appState) {
        if (appState is! SkarnikAppInitedState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return BlocProvider(
          create: (context) => HistoryCubit(
            loadHistoryUseCase: getIt<LoadHistoryUseCase>(),
          ),
          child: Builder(
            builder: (context) {
              final isRail = MediaQuery.sizeOf(context).width >= Breakpoints.rail;
              if (!isRail) {
                return Scaffold(
                  body: navigationShell,
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: navigationShell.goBranch,
                    destinations: [
                      for (final destination in _destinations)
                        NavigationDestination(
                          icon: Icon(destination.icon),
                          label: destination.label,
                        ),
                    ],
                  ),
                );
              }

              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: navigationShell.goBranch,
                      labelType: NavigationRailLabelType.all,
                      trailing: const Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: SettingsButton(),
                          ),
                        ),
                      ),
                      destinations: [
                        for (final destination in _destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: navigationShell),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
