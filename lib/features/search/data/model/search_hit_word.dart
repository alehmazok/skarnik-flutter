import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

class SearchHitWord {
  final String id;
  final int externalId;
  final String direction;
  final String letter;
  final String text;
  final String translation;

  SearchHitWord({
    required this.id,
    required this.externalId,
    required this.direction,
    required this.letter,
    required this.text,
    required this.translation,
  });

  factory SearchHitWord.fromMap(Map<String, dynamic> data) {
    final document = data['document'];
    return SearchHitWord(
      id: document['id'],
      externalId: document['external_id'],
      direction: document['direction'],
      letter: document['letter'],
      text: document['text'],
      translation: document['translation'],
    );
  }
}

extension SearchHitWordMapper on SearchHitWord {
  Word toEntity() {
    final dictionary = Dictionary.byPath(direction);
    return Word(
      wordId: externalId,
      langId: dictionary.langId,
      letter: letter,
      word: text,
      lword: text.toLowerCase(),
      dictionary: dictionary,
    );
  }
}
