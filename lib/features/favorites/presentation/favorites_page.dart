import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/remove_from_favorites.dart';

import '../domain/use_case/load_favorites.dart';
import 'favorites_cubit.dart';
import 'widgets/favorites_list_view.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesCubit(
        loadFavoritesUseCase: getIt<LoadFavoritesUseCase>(),
        removeFromFavoritesUseCase: getIt<RemoveFromFavoritesUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          title: SizedBox(
            width: double.infinity,
            height: 56,
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(56),
              ),
              onTap: () => context.go('/search'),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  borderRadius: BorderRadius.circular(56),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.search, size: 24),
                    ),
                    Text(
                      'Пошук слоў',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () => context.go(
                    '/settings',
                    extra: context.read<FavoritesCubit>(),
                  ),
                  icon: const Icon(Icons.settings_rounded),
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
