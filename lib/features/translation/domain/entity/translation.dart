import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

class Translation extends Equatable {
  final Word word;
  final Uri uri;
  final String? stress;
  final String html;
  final String source;

  String get maybeStressedWord => stress ?? word.word;

  late final List<String> stressCandidates = switch (word.dictionary) {
    Dictionary.tsbm => word.word.contains(' ') ? const [] : [word.word],
    Dictionary.belRus || Dictionary.rusBel => _extractRusBelCandidates(html),
  };

  static List<String> _extractRusBelCandidates(String html) {
    final fontPattern = RegExp(
      r'''<font[^>]*color=["']#831b03["'][^>]*>(.*?)</font>''',
      dotAll: true,
      caseSensitive: false,
    );
    final candidates = <String>{};
    for (final match in fontPattern.allMatches(html)) {
      final text = match.group(1)!.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      for (final part in text.split(',')) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty && !trimmed.contains(' ')) {
          candidates.add(trimmed);
        }
      }
    }
    return candidates.sorted().toList();
  }

  @override
  List<Object?> get props => [
    word,
    uri,
    html,
    source,
  ];

  Uri get shareUri => Uri.parse(
    'https://${AppConfig.skarnikAppSiteHostName}/r/${word.dictionary.path}/${word.wordId}',
  );

  Translation._({
    required this.uri,
    required this.word,
    this.stress,
    required this.html,
    required this.source,
  });

  factory Translation.build({
    required Uri uri,
    required Word word,
    required String html,
    String? stress,
    required String source,
  }) {
    return Translation._(
      uri: uri,
      word: word,
      stress: stress,
      html: _modifyHtml(html),
      source: source,
    );
  }

  static String _modifyHtml(String html) {
    return html.replaceAll(RegExp('color="#?'), 'color="#');
  }
}
