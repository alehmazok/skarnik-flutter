import 'word.dart';

extension SkarnikWordExt on Word {
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
