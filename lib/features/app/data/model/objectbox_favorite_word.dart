import 'package:objectbox/objectbox.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

@Entity(uid: 3)
class ObjectboxFavoriteWord implements Word {
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
  @Transient()
  String lword;

  @override
  @Transient()
  String? lwordMask;

  ObjectboxFavoriteWord({
    required this.langId,
    required this.letter,
    required this.wordId,
    required this.word,
    this.lword = '',
  });

  factory ObjectboxFavoriteWord.fromWord(Word word) => ObjectboxFavoriteWord(
        langId: word.langId,
        letter: word.letter,
        wordId: word.wordId,
        word: word.word,
      );

  @override
  String toString() => 'ObjectboxFavoriteWord(id: $id, $langId, $letter, $wordId, $word)';
}
