import 'package:objectbox/objectbox.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

@Entity(uid: 3)
class ObjectboxFavoriteWord {
  @Id()
  int id = 0;

  int langId;

  String letter;

  int wordId;

  String word;

  ObjectboxFavoriteWord({
    required this.langId,
    required this.letter,
    required this.wordId,
    required this.word,
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

extension ObjectboxFavoriteWordExt on ObjectboxFavoriteWord {
  Word toEntity() => Word(
        langId: langId,
        letter: letter,
        wordId: wordId,
        word: word,
        dictionary: Dictionary.byLangId(langId),
        lword: '',
        lwordMask: null,
      );
}
