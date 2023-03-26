import 'package:flutter/material.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

class HistoryListView extends StatelessWidget {
  final Iterable<Word> words;

  const HistoryListView({
    Key? key,
    required this.words,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final words = this.words.toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        final word = words[index];
        return ListTile(
          title: Text(word.word),
          subtitle: Text(word.dictName),
        );
      },
      itemCount: words.length,
    );
  }
}
