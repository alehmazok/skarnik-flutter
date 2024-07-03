import 'package:flutter/material.dart';

class SearchListView<I> extends StatelessWidget {
  final bool isNothingFound;
  final Iterable<I> items;
  final Widget Function(I item) itemBuilder;

  const SearchListView({
    super.key,
    required this.isNothingFound,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isNothingFound) {
      return const Center(
        child: Text('Па запыце нічога не знойдзена'),
      );
    } else if (this.items.isEmpty) {
      return const Center(
        child: Text('Пошук з аўтаматычнай падменай і|и, ў|щ, \'|ь|ъ, е|ё'),
      );
    }

    final items = this.items.toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        final item = items[index];
        return itemBuilder(item);
      },
      itemCount: items.length,
    );
  }
}
