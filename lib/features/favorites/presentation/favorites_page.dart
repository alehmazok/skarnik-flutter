import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/favorites/domain/entity/favorites_sort_order.dart';
import 'package:skarnik_flutter/features/favorites/domain/repository/favorites_sort_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart';
import 'package:skarnik_flutter/strings.dart';

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
        favoritesSortRepository: getIt<FavoritesSortRepository>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.bookmarks),
          actions: [
            Builder(
              builder: (context) {
                final cubit = context.read<FavoritesCubit>();
                return ValueListenableBuilder<FavoritesSortOrder>(
                  valueListenable: cubit.sortOrder,
                  builder: (context, sortOrder, _) => PopupMenuButton<FavoritesSortOrder>(
                    icon: const Icon(Icons.sort_rounded),
                    initialValue: sortOrder,
                    onSelected: cubit.changeSortOrder,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: FavoritesSortOrder.dateAdded,
                        child: Text(Strings.sortByDateAdded),
                      ),
                      const PopupMenuItem(
                        value: FavoritesSortOrder.alphabetical,
                        child: Text(Strings.sortByLetter),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocListener<FavoritesCubit, FavoritesState>(
          listener: (context, state) {
            if (state is FavoritesRemovedState) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: const Text(Strings.removedFromBookmarks),
                    action: SnackBarAction(
                      label: Strings.revert,
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
