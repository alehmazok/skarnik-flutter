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

  const Translation._({
    required this.uri,
    required this.word,
    required this.html,
  });

  factory Translation.build({
    required Uri uri,
    required Word word,
    required String html,
  }) {
    return Translation._(
      uri: uri,
      word: word,
      html: _modifyHtml(html),
    );
  }

  static String _modifyHtml(String html) {
    return html.replaceAll(RegExp('color="#?'), 'color="#');
  }
}
