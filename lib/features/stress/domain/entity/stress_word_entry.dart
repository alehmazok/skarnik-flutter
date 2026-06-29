import 'package:equatable/equatable.dart';

class StressWordEntry extends Equatable {
  final int id;
  final String lemma;
  final String word;
  final String? tableName;

  @override
  List<Object?> get props => [
    id,
    lemma,
    word,
    tableName,
  ];

  const StressWordEntry({
    required this.id,
    required this.lemma,
    required this.word,
    this.tableName,
  });
}
