import 'package:equatable/equatable.dart';

class WidgetHistoryEntry extends Equatable {
  final int wordId;
  final String word;
  final String translation;
  final DateTime createdAt;
  final bool isSimilar;

  const WidgetHistoryEntry({
    required this.wordId,
    required this.word,
    required this.translation,
    required this.createdAt,
    required this.isSimilar,
  });

  @override
  List<Object?> get props => [wordId, word, translation, createdAt, isSimilar];

  Map<String, dynamic> toJson() => {
    'wordId': wordId,
    'word': word,
    'translation': translation,
    'createdAt': createdAt.toIso8601String(),
    'isSimilar': isSimilar,
  };

  factory WidgetHistoryEntry.fromJson(Map<String, dynamic> json) => WidgetHistoryEntry(
    wordId: json['wordId'] as int,
    word: json['word'] as String,
    translation: json['translation'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isSimilar: json['isSimilar'] as bool,
  );
}
