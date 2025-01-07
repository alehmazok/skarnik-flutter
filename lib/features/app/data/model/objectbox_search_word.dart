import 'package:objectbox/objectbox.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';

import '../../domain/entity/search_word.dart';

@Entity(uid: 1)
class ObjectboxSearchWord implements SearchWord {
  @override
  @Id(assignable: false)
  int id = 0;

  @override
  int langId;

  @override
  String letter;

  @override
  @Unique()
  int wordId;

  @override
  String word;

  @override
  @Index(type: IndexType.value)
  String lword;

  @override
  @Index(type: IndexType.value)
  String? lwordMask;

  @override
  Dictionary dictionary;

  ObjectboxSearchWord({
    required this.langId,
    required this.letter,
    required this.wordId,
    required this.word,
    required this.lword,
    required this.lwordMask,
  }) : dictionary = Dictionary.byLangId(langId);

  @override
  String toString() => 'ObjectboxSearchWord($id, $langId, $letter, $wordId, $word, $lword, $lwordMask)';
}
