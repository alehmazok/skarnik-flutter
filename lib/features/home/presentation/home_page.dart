import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/widgets/adaptive_icons.dart';

import '../../app/presentation/skarnik_app_bloc.dart';
import '../../favorites/presentation/favorites_page.dart';
import '../../history/presentation/history_page.dart';
import '../../vocabulary/presentation/vocabulary_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const _pages = [
    HistoryPage(),
    FavoritesPage(),
    VocabularyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkarnikAppBloc, SkarnikAppState>(
      buildWhen: (_, current) => current is SkarnikAppInitedState,
      builder: (context, appState) {
        if (appState is SkarnikAppInitedState) {
          return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() {
                _selectedIndex = index;
              }),
              destinations: [
                NavigationDestination(
                  icon: Icon(AdaptiveIcons.search),
                  label: 'Пошук',
                ),
                NavigationDestination(
                  icon: Icon(AdaptiveIcons.bookmark),
                  label: 'Закладкі',
                ),
                NavigationDestination(
                  icon: Icon(AdaptiveIcons.book),
                  label: 'Слоўнік',
                ),
              ],
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
