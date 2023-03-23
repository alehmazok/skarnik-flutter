import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

class SearchListView extends StatelessWidget {
  final Iterable<Word> words;

  const SearchListView({
    Key? key,
    required this.words,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = words.toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final word = items[index];

        return ListTile(
          title: Text(word.word),
          subtitle: Text(
            word.dictName,
          ),
          onTap: () => context.push(
            '/translate/word',
            extra: word,
          ),
        );
      },
      itemCount: items.length,
    );
  }
}
