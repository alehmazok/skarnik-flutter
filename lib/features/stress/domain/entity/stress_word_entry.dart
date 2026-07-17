import 'package:equatable/equatable.dart';

import 'stress_source.dart';

class StressWordEntry extends Equatable {
  final int id;
  final String lemma;
  final String word;
  final String? tableName;
  final StressSource source;

  @override
  List<Object?> get props => [
    id,
    lemma,
    word,
    tableName,
    source,
  ];

  const StressWordEntry({
    required this.id,
    required this.lemma,
    required this.word,
    required this.source,
    this.tableName,
  });
}
