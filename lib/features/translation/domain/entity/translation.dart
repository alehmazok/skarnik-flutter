import 'package:equatable/equatable.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

class Translation extends Equatable {
  final Word word;
  final Uri uri;
  final String html;

  @override
  List<Object?> get props => [
        word,
        uri,
        html,
      ];

  const Translation({
    required this.uri,
    required this.word,
    required this.html,
  });
}
