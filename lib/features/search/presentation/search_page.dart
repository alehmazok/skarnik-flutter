import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';

import '../domain/use_case/search_use_case.dart';
import 'search_cubit.dart';
import 'widgets/search_extra_buttons.dart';
import 'widgets/search_list_view.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>(
      create: (context) => SearchCubit(
        searchUseCase: getIt<SearchUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: SizedBox(
            height: 56,
            child: Builder(
              builder: (context) {
                final cubit = context.read<SearchCubit>();
                return TextField(
                  controller: cubit.searchTextController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search words',
                    border: InputBorder.none,
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => cubit.clearSearch(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          buildWhen: (_, current) => current is SearchLoadedState,
          builder: (context, state) {
            if (state is SearchLoadedState) {
              return SearchListView(words: state.items);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<SearchCubit, SearchState>(
          buildWhen: (_, current) => current is SearchKeyboardChangedState,
          builder: (context, state) {
            if (state is SearchKeyboardChangedState && state.isVisible) {
              return const SearchExtraButtons();
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
