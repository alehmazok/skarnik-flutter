import 'package:equatable/equatable.dart';
import 'package:skarnik_flutter/app_config.dart';

import 'dictionary.dart';

class Word extends Equatable {
  final int langId;

  final String letter;

  final int wordId;

  final String word;

  final String lword;

  final String? lwordMask;

  final Dictionary dictionary;

  @override
  List<Object?> get props => [wordId];

  const Word({
    required this.langId,
    required this.letter,
    required this.wordId,
    required this.word,
    required this.dictionary,
    required this.lword,
    required this.lwordMask,
  });

  Uri buildApiUri() => Uri.parse(
        '${AppConfig.apiHostName}/api/words/${dictionary.path}/$wordId/',
      );

  @override
  String toString() => 'Word($langId, $letter, $wordId, $word, $lword, $lwordMask)';
}
