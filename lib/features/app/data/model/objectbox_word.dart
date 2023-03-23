import 'package:objectbox/objectbox.dart';

import '../../domain/entity/word.dart';

@Entity(uid: 1)
class ObjectboxWord implements Word {
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

  ObjectboxWord({
    required this.langId,
    required this.letter,
    required this.wordId,
    required this.word,
    required this.lword,
    required this.lwordMask,
  });

  @override
  String toString() => 'ObjectboxWord(id: $id, $langId, $letter, $wordId, $word, $lword, $lwordMask)';
}
