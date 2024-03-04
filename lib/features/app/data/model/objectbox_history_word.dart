import 'package:objectbox/objectbox.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

@Entity(uid: 2)
class ObjectboxHistoryWord implements Word {
  @Id()
  int id = 0;

  @override
  int langId;

  @override
  String letter;

  @override
  int wordId;

  @override
  String word;

  @override
  String lword;

  @override
  String? lwordMask;

  @override
  @Transient()
  Dictionary dictionary;

  ObjectboxHistoryWord({
    required this.langId,
    required this.letter,
    required this.wordId,
    required this.word,
    required this.lword,
    required this.lwordMask,
  }) : dictionary = Dictionary.byLangId(langId);

  factory ObjectboxHistoryWord.fromWord(Word word) => ObjectboxHistoryWord(
        langId: word.langId,
        letter: word.letter,
        wordId: word.wordId,
        word: word.word,
        lword: word.lword,
        lwordMask: word.lwordMask,
      );

  @override
  String toString() => 'ObjectboxHistoryWord(id: $id, $langId, $letter, $wordId, $word, $lword, $lwordMask)';
}
