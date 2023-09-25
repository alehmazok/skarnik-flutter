import 'word.dart';

const int langIdRusBel = 0;
const int langIdBelRus = 1;
const int langIdTsbm = 2;

const String dictPathRusBel = 'rusbel';
const String dictPathBelRus = 'belrus';
const String dictPathTsbm = 'tsbm';

extension SkarnikWordExt on Word {
  static const langIdDictPathMap = {
    langIdRusBel: dictPathRusBel,
    langIdBelRus: dictPathBelRus,
    langIdTsbm: dictPathTsbm,
  };

  static int getLangId(String dictPath) {
    switch (dictPath) {
      case dictPathRusBel:
        return langIdRusBel;
      case dictPathBelRus:
        return langIdBelRus;
      case dictPathTsbm:
        return langIdTsbm;
    }
    throw ArgumentError('Невядомы path слоўніка: ’$dictPath`');
  }

  String get dictPath {
    final value = langIdDictPathMap[langId];
    if (value != null) {
      return value;
    }
    throw ArgumentError('Невядомы id слоўніка: ’$langId’');
  }

  String get dictName {
    switch (langId) {
      case langIdRusBel:
        return 'РУСКА-БЕЛАРУСКІ';
      case langIdBelRus:
        return 'БЕЛАРУСКА-РУСКІ';
      case langIdTsbm:
        return 'ТЛУМАЧАЛЬНЫ';
    }
    throw ArgumentError('Невядомы id слоўніка: ’$langId’');
  }

  String get translationDirection {
    switch (langId) {
      case langIdRusBel:
        return 'ПЕРАКЛАД НА БЕЛАРУСКУЮ МОВУ';
      case langIdBelRus:
        return 'ПЕРАКЛАД НА РУСКУЮ МОВУ';
      case langIdTsbm:
        return 'ТЛУМАЧЭННЕ СЛОВА';
    }
    throw ArgumentError('Невядомы id слоўніка: ’$langId’');
  }
}
