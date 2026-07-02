import 'package:flutter_test/flutter_test.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/translation/domain/entity/translation.dart';

Word _word(String wordStr, Dictionary dictionary) => Word(
  langId: dictionary.langId,
  letter: wordStr[0],
  wordId: 1,
  word: wordStr,
  dictionary: dictionary,
  lword: wordStr.toLowerCase(),
  lwordMask: null,
);

Translation _translation({
  required Word word,
  String html = '',
  String? stress,
}) => Translation.build(
  uri: Uri.parse('https://skarnik.by/${word.dictionary.path}/${word.wordId}'),
  word: word,
  html: html,
  stress: stress,
  source: 'test',
);

void main() {
  group('Translation', () {
    group('maybeStressedWord', () {
      test('returns stress when set', () {
        final t = _translation(word: _word('слова', Dictionary.belRus), stress: 'сло́ва');
        expect(t.maybeStressedWord, 'сло́ва');
      });

      test('returns word.word when stress is null', () {
        final t = _translation(word: _word('слова', Dictionary.belRus));
        expect(t.maybeStressedWord, 'слова');
      });
    });

    group('stressCandidates', () {
      group('belRus', () {
        test('single word → [word]', () {
          final t = _translation(word: _word('слова', Dictionary.belRus));
          expect(t.stressCandidates, ['слова']);
        });

        test('multi-word phrase → []', () {
          final t = _translation(word: _word('добры дзень', Dictionary.belRus));
          expect(t.stressCandidates, isEmpty);
        });
      });

      group('tsbm', () {
        test('single word → [word]', () {
          final t = _translation(word: _word('імаверны', Dictionary.tsbm));
          expect(t.stressCandidates, ['імаверны']);
        });

        test('multi-word phrase → []', () {
          final t = _translation(word: _word('добры дзень', Dictionary.tsbm));
          expect(t.stressCandidates, isEmpty);
        });
      });

      group('rusBel', () {
        test('no matching font tags → []', () {
          final t = _translation(
            word: _word('примечательный', Dictionary.rusBel),
            html: '<p>some text</p>',
          );
          expect(t.stressCandidates, isEmpty);
        });

        test('other color font tag → []', () {
          final t = _translation(
            word: _word('примечательный', Dictionary.rusBel),
            html: '<font color="#5f5f5f">варты ўвагі</font>',
          );
          expect(t.stressCandidates, isEmpty);
        });

        test('extracts single word from font tag', () {
          final t = _translation(
            word: _word('знаменательный', Dictionary.rusBel),
            html: '<font size="+2" color="#831b03">знамянальны</font>',
          );
          expect(t.stressCandidates, ['знамянальны']);
        });

        test('filters multi-word entries', () {
          final t = _translation(
            word: _word('примечательный', Dictionary.rusBel),
            html: '<font size="+2" color="#831b03">варты ўвагі</font>',
          );
          expect(t.stressCandidates, isEmpty);
        });

        test('splits on comma → multiple single words', () {
          final t = _translation(
            word: _word('характерный', Dictionary.rusBel),
            html: '<font size="+2" color="#831b03">характэрны, паказальны</font>',
          );
          expect(t.stressCandidates, unorderedEquals(['характэрны', 'паказальны']));
        });

        test('deduplicates repeated words', () {
          final t = _translation(
            word: _word('интересный', Dictionary.rusBel),
            html: '<font size="+2" color="#831b03">цікавы</font>'
                '<font size="+2" color="#831b03">цікавы</font>',
          );
          expect(t.stressCandidates, ['цікавы']);
        });

        test('extracts from multiple font tags, skips multi-word', () {
          final t = _translation(
            word: _word('примечательный', Dictionary.rusBel),
            html: '''
              <font size="+2" color="#831b03">варты ўвагі</font>
              <font size="+2" color="#831b03">знамянальны</font>
              <font size="+2" color="#831b03">характэрны, паказальны</font>
              <font size="+2" color="#831b03">цікавы</font>
            ''',
          );
          expect(
            t.stressCandidates,
            unorderedEquals(['знамянальны', 'характэрны', 'паказальны', 'цікавы']),
          );
        });

        test('results are sorted', () {
          final t = _translation(
            word: _word('знаменательный', Dictionary.rusBel),
            html: '<font size="+2" color="#831b03">цікавы, знамянальны</font>',
          );
          expect(t.stressCandidates, ['знамянальны', 'цікавы']);
        });

        test('color without # is normalised and still extracted', () {
          final t = _translation(
            word: _word('знаменательный', Dictionary.rusBel),
            html: '<font size="+2" color="831b03">знамянальны</font>',
          );
          expect(t.stressCandidates, ['знамянальны']);
        });
      });

      group('caching', () {
        test('same list instance on repeated access', () {
          final t = _translation(
            word: _word('примечательный', Dictionary.rusBel),
            html: '<font size="+2" color="#831b03">цікавы</font>',
          );
          expect(identical(t.stressCandidates, t.stressCandidates), isTrue);
        });
      });
    });

    group('Translation.build', () {
      test('adds # to color attributes missing it', () {
        final t = _translation(
          word: _word('примечательный', Dictionary.rusBel),
          html: '<font color="831b03">цікавы</font>',
        );
        expect(t.html, contains('color="#831b03"'));
      });

      test('keeps # in color attributes that already have it', () {
        final t = _translation(
          word: _word('примечательный', Dictionary.rusBel),
          html: '<font color="#831b03">цікавы</font>',
        );
        expect(t.html, contains('color="#831b03"'));
      });
    });

    group('equality', () {
      test('equal when word, uri, html, source match', () {
        final word = _word('слова', Dictionary.belRus);
        final uri = Uri.parse('https://skarnik.by/belrus/1');
        final t1 = Translation.build(uri: uri, word: word, html: '<p>test</p>', source: 'api');
        final t2 = Translation.build(uri: uri, word: word, html: '<p>test</p>', source: 'api');
        expect(t1, equals(t2));
      });

      test('not equal when html differs', () {
        final word = _word('слова', Dictionary.belRus);
        final uri = Uri.parse('https://skarnik.by/belrus/1');
        final t1 = Translation.build(uri: uri, word: word, html: '<p>a</p>', source: 'api');
        final t2 = Translation.build(uri: uri, word: word, html: '<p>b</p>', source: 'api');
        expect(t1, isNot(equals(t2)));
      });

      test('not equal when source differs', () {
        final word = _word('слова', Dictionary.belRus);
        final uri = Uri.parse('https://skarnik.by/belrus/1');
        final t1 = Translation.build(uri: uri, word: word, html: '<p>x</p>', source: 'api');
        final t2 = Translation.build(uri: uri, word: word, html: '<p>x</p>', source: 'cloud');
        expect(t1, isNot(equals(t2)));
      });
    });
  });
}
