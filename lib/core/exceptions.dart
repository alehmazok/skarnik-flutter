import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

class TranslationRedirectError extends Error {
  final Word word;
  final String redirectTo;

  TranslationRedirectError({
    required this.word,
    required this.redirectTo,
  });
}
