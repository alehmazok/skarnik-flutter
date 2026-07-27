import 'package:equatable/equatable.dart';

class WordOfTheDay extends Equatable {
  final int wordId;
  final String word;
  final String translation;

  const WordOfTheDay({required this.wordId, required this.word, required this.translation});

  @override
  List<Object?> get props => [wordId, word, translation];
}
