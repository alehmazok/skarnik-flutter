import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_bloc.dart';

import '../../history/presentation/history_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../vocabulary/presentation/vocabulary_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const _pages = [
    HistoryPage(),
    VocabularyPage(),
    SettingsPage(),
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
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Пошук',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_rounded),
                  label: 'Слоўнік',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Наладкі',
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
