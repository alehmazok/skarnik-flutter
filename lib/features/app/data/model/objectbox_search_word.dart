import 'package:equatable/equatable.dart';
import 'package:objectbox/objectbox.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

@Entity(uid: 1)
class ObjectboxSearchWord with EquatableMixin {
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

  @override
  List<Object?> get props => [id];
}

extension ObjectboxSearchWordMapper on ObjectboxSearchWord {
  Word toEntity() => Word(
        langId: langId,
        letter: letter,
        wordId: wordId,
        word: word,
        lword: lword,
        lwordMask: lwordMask,
        dictionary: Dictionary.byLangId(langId),
      );
}
