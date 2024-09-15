import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/strings.dart';

class SearchListView extends StatelessWidget {
  final bool isNothingFound;
  final Iterable<Word> words;

  const SearchListView({
    super.key,
    required this.isNothingFound,
    required this.words,
  });

  @override
  Widget build(BuildContext context) {
    if (isNothingFound) {
      return const Center(
        child: Text(Strings.nothingFound),
      );
    } else if (words.isEmpty) {
      return const Center(
        child: Text(Strings.searchNote),
      );
    }

    final items = words.toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        final word = items[index];

        return ListTile(
          title: Text(word.word),
          subtitle: Text(
            word.dictionary.name,
          ),
          onTap: () => context.push(
            '/translate/word',
            extra: {
              'word': word,
              'save_to_history': true,
            },
          ),
        );
      },
      itemCount: items.length,
    );
  }
}
