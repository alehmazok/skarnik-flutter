import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/skarnik_word_ext.dart';

@injectable
class HandleAppLinkUseCase {
  final _logger = getLogger(HandleAppLinkUseCase);

  HandleAppLinkUseCase();

  Future<UseCaseResult<({int langId, int wordId})>> call(String argument) async {
    final appLink = argument;
    try {
      _logger.fine('Уваходзячы апп лінк: $appLink');
      final regex = RegExp(r'https?://(www.)?skarnik.by/(?<dictPath>belrus|rusbel|tsbm)/(?<wordId>[0-9]+)');
      if (!regex.hasMatch(appLink)) {
        throw ArgumentError('Не атрымалася распарсіць app link');
      }
      final matches = regex.allMatches(appLink);
      final dictPath = matches.first.namedGroup('dictPath');
      final wordId = matches.first.namedGroup('wordId');
      final pair = (
        langId: SkarnikWordExt.getLangId(dictPath!),
        wordId: int.parse(wordId!),
      );
      _logger.fine('langId, wordId: $pair');
      return Success(pair);
    } catch (e, st) {
      _logger.severe('Адбылася памылка апрацоўкі app link `$appLink`', e, st);
      return Failure(e);
    }
  }
}
