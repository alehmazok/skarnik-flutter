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
}

extension SearchWordExt on SearchWord {
  Word toEntity() => Word(
        langId: langId,
        letter: letter,
        wordId: wordId,
        word: word,
        dictionary: Dictionary.byLangId(langId),
        lword: lword,
        lwordMask: lwordMask,
      );
}
