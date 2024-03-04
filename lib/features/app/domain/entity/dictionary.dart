const int langIdRusBel = 0;
const int langIdBelRus = 1;
const int langIdTsbm = 2;

const String dictPathRusBel = 'rusbel';
const String dictPathBelRus = 'belrus';
const String dictPathTsbm = 'tsbm';

const langIdMap = {
  langIdBelRus: Dictionary.belRus,
  langIdRusBel: Dictionary.rusBel,
  langIdTsbm: Dictionary.tsbm,
};

const dictPathMap = {
  dictPathBelRus: Dictionary.belRus,
  dictPathRusBel: Dictionary.rusBel,
  dictPathTsbm: Dictionary.tsbm,
};

enum Dictionary {
  belRus(
    langId: langIdBelRus,
    path: dictPathBelRus,
    name: 'БЕЛАРУСКА-РУСКІ',
    translationName: 'ПЕРАКЛАД НА РУСКУЮ МОВУ',
  ),
  rusBel(
    langId: langIdRusBel,
    path: dictPathRusBel,
    name: 'РУСКА-БЕЛАРУСКІ',
    translationName: 'ПЕРАКЛАД НА БЕЛАРУСКУЮ МОВУ',
  ),
  tsbm(
    langId: langIdTsbm,
    path: dictPathTsbm,
    name: 'ТЛУМАЧЭННЕ СЛОВА',
    translationName: 'ТЛУМАЧЭННЕ СЛОВА',
  );

  final int langId;
  final String path;
  final String name;
  final String translationName;

  const Dictionary({
    required this.langId,
    required this.path,
    required this.name,
    required this.translationName,
  });

  factory Dictionary.byPath(String path) => dictPathMap[path]!;

  factory Dictionary.byLangId(int langId) => langIdMap[langId]!;
}
