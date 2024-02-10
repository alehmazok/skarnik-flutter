import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart';

import '../domain/use_case/load_favorites.dart';
import 'favorites_cubit.dart';
import 'widgets/favorites_list_view.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesCubit(
        loadFavoritesUseCase: getIt<LoadFavoritesUseCase>(),
        removeFromFavoritesUseCase: getIt<RemoveFromFavoritesUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Закладкі'),
        ),
        body: BlocListener<FavoritesCubit, FavoritesState>(
          listener: (context, state) {
            if (state is FavoritesRemovedState) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Выдалена з закладак.',
                    ),
                    action: SnackBarAction(
                      label: 'Вярнуць',
                      onPressed: () => context.read<FavoritesCubit>().cancelRemoval(state.word),
                    ),
                  ),
                );
            }
          },
          child: const FavoritesListView(),
        ),
      ),
    );
  }
}
