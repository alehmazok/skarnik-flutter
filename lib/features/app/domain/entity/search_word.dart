import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import 'dictionary.dart';

abstract interface class SearchWord {
  int get id;

  int get langId;

  String get letter;

  int get wordId;

  String get word;

  String get lword;

  String? get lwordMask;

  Dictionary get dictionary;
}

extension SearchWordExt on SearchWord {
  Word toEntity() => Word(
        langId: langId,
        letter: letter,
        wordId: wordId,
        word: word,
        dictionary: dictionary,
        lword: lword,
        lwordMask: lwordMask,
      );
}
