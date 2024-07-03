import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

class SearchHitWord {
  final String id;
  final int wordId;
  final int langId;
  final String word;
  final String lword;
  final String lwordMask;

  SearchHitWord({
    required this.id,
    required this.wordId,
    required this.langId,
    required this.word,
    required this.lword,
    required this.lwordMask,
  });

  factory SearchHitWord.fromMap(Map<String, dynamic> data) {
    final document = data['document'];
    return SearchHitWord(
      id: document['id'],
      wordId: int.parse(document['wordId']),
      word: document['word'],
      lword: document['lword'],
      lwordMask: document['lwordMask'],
      langId: document['langId'],
    );
  }
}

extension SearchHitWordMapper on SearchHitWord {
  Word toEntity() => Word(
        langId: langId,
        letter: '',
        wordId: wordId,
        word: word,
        lword: lword,
        lwordMask: lwordMask,
        dictionary: Dictionary.byLangId(langId),
      );
}
