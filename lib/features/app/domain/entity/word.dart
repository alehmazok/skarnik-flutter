abstract interface class Word {
  int get langId;

  String get letter;

  int get wordId;

  String get word;

  String get lword;

  String? get lwordMask;

  @override
  String toString() => 'Word($langId, $letter, $wordId, $word, $lword, $lwordMask)';
}
