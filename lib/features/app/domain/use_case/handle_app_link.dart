import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/core/pair.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/skarnik_word_ext.dart';

@injectable
class HandleAppLinkUseCase extends EitherUseCase1<Pair<int, int>, String> {
  final _logger = getLogger(HandleAppLinkUseCase);

  HandleAppLinkUseCase();

  @override
  Future<Either<Object, Pair<int, int>>> call(String argument) async {
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
      final pair = Pair(
        SkarnikWordExt.getLangId(dictPath!),
        int.parse(wordId!),
      );
      _logger.fine('langId, wordId: $pair');
      return right(pair);
    } catch (e, st) {
      _logger.severe('Адбылася памылка апрацоўкі app link `$appLink`', e, st);
      return left(e);
    }
  }
}
