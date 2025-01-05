import 'package:objectbox/objectbox.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../../domain/entity/word.dart';

@Entity(uid: 1)
class ObjectboxSearchWord {
  @Id(assignable: false)
  int id = 0;

  int langId;

  String letter;

  @Unique()
  int wordId;

  String word;

  String lword;

  String? lwordMask;

  ObjectboxSearchWord({
    required this.langId,
    required this.letter,
    required this.wordId,
    required this.word,
    required this.lword,
    required this.lwordMask,
  });

  @override
  String toString() => 'ObjectboxSearchWord($id, $langId, $letter, $wordId, $word, $lword, $lwordMask)';
}

extension ObjectboxSearchWordExt on ObjectboxSearchWord {
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
