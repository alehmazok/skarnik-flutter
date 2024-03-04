import 'dictionary.dart';

abstract interface class Word {
  int get langId;

  String get letter;

  int get wordId;

  String get word;

  String get lword;

  String? get lwordMask;

  Dictionary get dictionary;

  @override
  String toString() => 'Word($langId, $letter, $wordId, $word, $lword, $lwordMask)';
}
