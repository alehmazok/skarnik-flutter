import 'package:equatable/equatable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import 'translation.dart';

class ApiWord extends Equatable {
  final int externalId;
  final String? stress;
  final String translation;
  final String? redirectTo;

  @override
  List<Object?> get props => [
    externalId,
    stress,
    translation,
    redirectTo,
  ];

  const ApiWord({
    required this.externalId,
    required this.translation,
    required this.redirectTo,
    this.stress,
  });

  Translation toTranslation({
    required Word word,
    required String source,
  }) => Translation.build(
    uri: word.buildApiUri(),
    word: word,
    stress: stress,
    html: translation,
    source: source,
  );
}
