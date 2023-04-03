import 'word.dart';

extension SkarnikWordExt on Word {
  static int getLangId(String dictPath) {
    switch (dictPath) {
      case 'rusbel':
        return 0;
      case 'belrus':
        return 1;
      case 'tsbm':
        return 2;
    }
    throw ArgumentError('Невядомы path слоўніка: ’$dictPath`');
  }

  String get dictPath {
    switch (langId) {
      case 0:
        return 'rusbel';
      case 1:
        return 'belrus';
      case 2:
        return 'tsbm';
    }
    throw ArgumentError('Невядомы id слоўніка: ’$langId’');
  }

  String get dictName {
    switch (langId) {
      case 0:
        return 'РУСКА-БЕЛАРУСКІ';
      case 1:
        return 'БЕЛАРУСКА-РУСКІ';
      case 2:
        return 'ТЛУМАЧАЛЬНЫ';
    }
    throw ArgumentError('Невядомы id слоўніка: ’$langId’');
  }

  String get translationDirection {
    switch (langId) {
      case 0:
        return 'ПЕРАКЛАД НА БЕЛАРУСКУЮ МОВУ';
      case 1:
        return 'ПЕРАКЛАД НА РУСКУЮ МОВУ';
      case 2:
        return 'ТЛУМАЧЭННЕ СЛОВА';
    }
    throw ArgumentError('Невядомы id слоўніка: ’$langId’');
  }
}
