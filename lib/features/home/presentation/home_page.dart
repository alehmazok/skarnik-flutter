import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/presentation/skarnik_app_bloc.dart';
import '../../favorites/presentation/favorites_page.dart';
import '../../history/presentation/history_page.dart';
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
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.search_rounded),
                  label: 'Пошук',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_rounded),
                  label: 'Закладкі',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_rounded),
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
