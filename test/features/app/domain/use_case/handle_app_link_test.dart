import 'package:flutter_test/flutter_test.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/use_case/handle_app_link.dart';

void main() {
  late HandleAppLinkUseCase useCase;

  setUp(() {
    useCase = HandleAppLinkUseCase();
  });

  group('HandleAppLinkUseCase', () {
    const wordId = 1000;

    for (final dictionary in Dictionary.values) {
      for (final host in ['skarnik.by', 'www.skarnik.by']) {
        final link = 'https://$host/${dictionary.path}/$wordId';
        test('parses `$link` into langId=${dictionary.langId}, wordId=$wordId', () async {
          final result = await useCase.call(link);

          expect(result, isA<Success<({int langId, int wordId})>>());
          final pair = (result as Success<({int langId, int wordId})>).result;
          expect(pair.langId, dictionary.langId);
          expect(pair.wordId, wordId);
        });
      }

      for (final host in ['skarnik.app', 'www.skarnik.app']) {
        final link = 'https://$host/r/${dictionary.path}/$wordId';
        test('parses `$link` into langId=${dictionary.langId}, wordId=$wordId', () async {
          final result = await useCase.call(link);

          expect(result, isA<Success<({int langId, int wordId})>>());
          final pair = (result as Success<({int langId, int wordId})>).result;
          expect(pair.langId, dictionary.langId);
          expect(pair.wordId, wordId);
        });
      }
    }

    test('parses a bare path without host or scheme', () async {
      final result = await useCase.call('/tsbm/$wordId');

      expect(result, isA<Success<({int langId, int wordId})>>());
      final pair = (result as Success<({int langId, int wordId})>).result;
      expect(pair.langId, Dictionary.tsbm.langId);
      expect(pair.wordId, wordId);
    });

    for (final badLink in [
      'https://skarnik.by/unknown/1000',
      'https://skarnik.by/belrus/notanumber',
      'not a link at all',
      '',
      'https://evil.com/search?url=/belrus/$wordId',
      'https://skarnik.by/belrus/$wordId/extra',
    ]) {
      test('returns Failure for unparsable link `$badLink`', () async {
        final result = await useCase.call(badLink);

        expect(result, isA<Failure<({int langId, int wordId})>>());
      });
    }
  });
}
