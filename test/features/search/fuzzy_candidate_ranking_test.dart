import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/search/data/util/fuzzy_candidate_ranking.dart';
import 'package:test/test.dart';

ObjectboxSearchWord _makeWord({
  int id = 1,
  int langId = 1,
  String letter = 'a',
  int wordId = 1,
  String word = 'aaa',
}) => ObjectboxSearchWord(
  langId: langId,
  letter: letter,
  wordId: wordId,
  word: word,
  lword: word,
  lwordMask: word,
)..id = id;

void main() {
  group('rankFuzzyCandidates()', () {
    test('filters out candidates beyond the distance threshold', () {
      final close = _makeWord(id: 1, wordId: 1, word: 'tost');
      final far = _makeWord(id: 2, wordId: 2, word: 'zzzz');

      final results = rankFuzzyCandidates(
        [close, far],
        searchQuery: 'test',
        maxDistance: 1,
        limit: 15,
      );

      expect(results, equals([close]));
    });

    test('sorts by distance then alphabetically', () {
      final exact = _makeWord(id: 1, wordId: 1, word: 'test');
      final oneAway = _makeWord(id: 2, wordId: 2, word: 'tost');
      final alsoOneAway = _makeWord(id: 3, wordId: 3, word: 'aest');

      final results = rankFuzzyCandidates(
        [oneAway, exact, alsoOneAway],
        searchQuery: 'test',
        maxDistance: 1,
        limit: 15,
      );

      expect(results, equals([exact, alsoOneAway, oneAway]));
    });

    test('caps results at the given limit', () {
      final candidates = List.generate(
        20,
        (i) => _makeWord(id: i + 1, wordId: i + 1, word: 'test'),
      );

      final results = rankFuzzyCandidates(
        candidates,
        searchQuery: 'test',
        maxDistance: 1,
        limit: 15,
      );

      expect(results.length, equals(15));
    });
  });
}
