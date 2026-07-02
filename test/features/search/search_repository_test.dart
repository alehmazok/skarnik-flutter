import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart';
import 'package:skarnik_flutter/features/search/domain/repository/query_repository.dart';
import 'package:test/test.dart';

class MockQueryRepository extends Mock implements QueryRepository {}

class MockSearchWord extends Mock implements SearchWord {}

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
  group('ObjectboxSearchRepository', () {
    late MockQueryRepository queryRepository;
    late ObjectboxSearchRepository searchRepository;

    setUp(() {
      queryRepository = MockQueryRepository();
      searchRepository = ObjectboxSearchRepository(queryRepository);
      when(
        () => queryRepository.queryByFirstLetter(
          firstLetter: any(named: 'firstLetter'),
          excluded: any(named: 'excluded'),
        ),
      ).thenReturn([]);
    });

    group('search()', () {
      test('returns results from queryByWord only', () async {
        final word1 = _makeWord();
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
          ),
        ).thenReturn([word1]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
            excluded: [word1],
          ),
        ).thenReturn([]);

        final results = await searchRepository.search('test');

        expect(results.length, equals(1));
        expect(results, contains(word1));
      });

      test('combines results from queryByWord and queryByWordMask', () async {
        final word1 = _makeWord(id: 1, wordId: 1, word: 'alpha');
        final word2 = _makeWord(id: 2, wordId: 2, word: 'beta');
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
          ),
        ).thenReturn([word1]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
            excluded: [word1],
          ),
        ).thenReturn([word2]);

        final results = await searchRepository.search('test');

        expect(results.length, equals(2));
        expect(results, containsAll([word1, word2]));
      });

      test('deduplicates results from both queries', () async {
        final word1 = _makeWord();
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
          ),
        ).thenReturn([word1]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
            excluded: [word1],
          ),
        ).thenReturn([word1]);

        final results = await searchRepository.search('test');

        expect(results.length, equals(1));
      });

      test('returns empty list when both queries return nothing', () async {
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'xyz',
            searchQueryWithSubstitutions: 'xyz',
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'xyz',
            searchQueryWithSubstitutions: 'xyz',
            excluded: [],
          ),
        ).thenReturn([]);

        final results = await searchRepository.search('xyz');

        expect(results, isEmpty);
      });

      test('lowercases query before passing to repositories', () async {
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
            excluded: [],
          ),
        ).thenReturn([]);

        await searchRepository.search('TEST');

        verify(
          () => queryRepository.queryByWord(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
          ),
        ).called(1);
      });

      test('applies letter substitutions to searchQueryWithSubstitutions', () async {
        // 'и' lowercased stays 'и', substituted becomes 'і'
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'и',
            searchQueryWithSubstitutions: 'і',
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'и',
            searchQueryWithSubstitutions: 'і',
            excluded: [],
          ),
        ).thenReturn([]);

        await searchRepository.search('и');

        verify(
          () => queryRepository.queryByWord(
            searchQuery: 'и',
            searchQueryWithSubstitutions: 'і',
          ),
        ).called(1);
      });

      test('lowercases before applying substitutions', () async {
        // Uppercase 'И' lowercased to 'и', then substituted to 'і'
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'и',
            searchQueryWithSubstitutions: 'і',
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'и',
            searchQueryWithSubstitutions: 'і',
            excluded: [],
          ),
        ).thenReturn([]);

        await searchRepository.search('И');

        verify(
          () => queryRepository.queryByWord(
            searchQuery: 'и',
            searchQueryWithSubstitutions: 'і',
          ),
        ).called(1);
      });

      test('queryByWordMask receives queryByWord results as excluded', () async {
        final word1 = _makeWord();
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
          ),
        ).thenReturn([word1]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
            excluded: [word1],
          ),
        ).thenReturn([]);

        await searchRepository.search('test');

        verify(
          () => queryRepository.queryByWordMask(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
            excluded: [word1],
          ),
        ).called(1);
      });

      test('preserves queryByWord results order before queryByWordMask results', () async {
        final word1 = _makeWord(id: 1, wordId: 1, word: 'alpha');
        final word2 = _makeWord(id: 2, wordId: 2, word: 'beta');
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
          ),
        ).thenReturn([word1]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'test',
            searchQueryWithSubstitutions: 'test',
            excluded: [word1],
          ),
        ).thenReturn([word2]);

        final results = await searchRepository.search('test');

        expect(results.toList(), equals([word1, word2]));
      });
    });

    group('applySubstitutions()', () {
      test('replaces и with і', () {
        expect(searchRepository.applySubstitutions('и'), equals('і'));
      });

      test('replaces е with ё', () {
        expect(searchRepository.applySubstitutions('е'), equals('ё'));
      });

      test('replaces щ with ў', () {
        expect(searchRepository.applySubstitutions('щ'), equals('ў'));
      });

      test('replaces ъ with left single quotation mark', () {
        expect(searchRepository.applySubstitutions('ъ'), equals('\u2018'));
      });

      test('replaces ASCII apostrophe with left single quotation mark', () {
        expect(searchRepository.applySubstitutions("'"), equals('\u2018'));
      });

      test('returns unchanged string when no substitutions apply', () {
        expect(searchRepository.applySubstitutions('skarnik'), equals('skarnik'));
      });

      test('applies multiple substitutions in one string', () {
        expect(
          searchRepository.applySubstitutions('иещъ'),
          equals('\u0456\u0451\u045E\u2018'),
        );
      });

      test('returns empty string unchanged', () {
        expect(searchRepository.applySubstitutions(''), equals(''));
      });
    });

    group('fuzzy search', () {
      void stubExact({
        required List<SearchWord> byWord,
        required List<SearchWord> byWordMask,
      }) {
        when(
          () => queryRepository.queryByWord(
            searchQuery: any(named: 'searchQuery'),
            searchQueryWithSubstitutions: any(named: 'searchQueryWithSubstitutions'),
          ),
        ).thenReturn(byWord);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: any(named: 'searchQuery'),
            searchQueryWithSubstitutions: any(named: 'searchQueryWithSubstitutions'),
            excluded: any(named: 'excluded'),
          ),
        ).thenReturn(byWordMask);
      }

      test(
        'does not call queryByFirstLetter when there is at least one exact/mask result',
        () async {
          final word1 = _makeWord();
          stubExact(byWord: [word1], byWordMask: []);

          await searchRepository.search('test');

          verifyNever(
            () => queryRepository.queryByFirstLetter(
              firstLetter: any(named: 'firstLetter'),
              excluded: any(named: 'excluded'),
            ),
          );
        },
      );

      test('calls queryByFirstLetter when there are zero exact/mask results', () async {
        stubExact(byWord: [], byWordMask: []);

        await searchRepository.search('test');

        verify(
          () => queryRepository.queryByFirstLetter(
            firstLetter: 't',
            excluded: any(named: 'excluded'),
          ),
        ).called(1);
      });

      test('does not call queryByFirstLetter for short queries even when sparse', () async {
        stubExact(byWord: [], byWordMask: []);

        await searchRepository.search('ab');

        verifyNever(
          () => queryRepository.queryByFirstLetter(
            firstLetter: any(named: 'firstLetter'),
            excluded: any(named: 'excluded'),
          ),
        );
      });

      test('queries the letter-substituted first letter, not the raw one', () async {
        // 'и' -> 'і' via applySubstitutions(); fuzzy should bucket on 'і'.
        stubExact(byWord: [], byWordMask: []);

        await searchRepository.search('иии');

        verify(
          () => queryRepository.queryByFirstLetter(
            firstLetter: 'і',
            excluded: any(named: 'excluded'),
          ),
        ).called(1);
      });

      test('returns fuzzy matches when exact and mask stages find nothing', () async {
        final fuzzyWord = _makeWord(id: 3, wordId: 3, word: 'tost');
        stubExact(byWord: [], byWordMask: []);
        when(
          () => queryRepository.queryByFirstLetter(
            firstLetter: 't',
            excluded: any(named: 'excluded'),
          ),
        ).thenReturn([fuzzyWord]);

        final results = await searchRepository.search('test');

        expect(results.toList(), equals([fuzzyWord]));
      });

      test('fuzzySearch() filters out candidates beyond the distance threshold', () {
        final close = _makeWord(id: 1, wordId: 1, word: 'tost');
        final far = _makeWord(id: 2, wordId: 2, word: 'zzzz');
        when(
          () => queryRepository.queryByFirstLetter(
            firstLetter: 't',
            excluded: any(named: 'excluded'),
          ),
        ).thenReturn([close, far]);

        final results = searchRepository.fuzzySearch('test', excluded: <SearchWord>{});

        expect(results, equals([close]));
      });

      test('fuzzySearch() sorts by distance then alphabetically', () {
        final exact = _makeWord(id: 1, wordId: 1, word: 'test');
        final oneAway = _makeWord(id: 2, wordId: 2, word: 'tost');
        final alsoOneAway = _makeWord(id: 3, wordId: 3, word: 'aest');
        when(
          () => queryRepository.queryByFirstLetter(
            firstLetter: 't',
            excluded: any(named: 'excluded'),
          ),
        ).thenReturn([oneAway, exact, alsoOneAway]);

        final results = searchRepository.fuzzySearch('test', excluded: <SearchWord>{});

        expect(results, equals([exact, alsoOneAway, oneAway]));
      });

      test('fuzzySearch() caps results at wordsSearchLimit', () {
        final candidates = List.generate(
          20,
          (i) => _makeWord(id: i + 1, wordId: i + 1, word: 'test'),
        );
        when(
          () => queryRepository.queryByFirstLetter(
            firstLetter: 't',
            excluded: any(named: 'excluded'),
          ),
        ).thenReturn(candidates);

        final results = searchRepository.fuzzySearch('test', excluded: <SearchWord>{});

        expect(results.length, equals(15));
      });

      test('deduplicates a fuzzy candidate that collides with an existing result', () async {
        final word1 = _makeWord(id: 1, wordId: 1, word: 'test');
        stubExact(byWord: [word1], byWordMask: []);
        when(
          () => queryRepository.queryByFirstLetter(
            firstLetter: 't',
            excluded: any(named: 'excluded'),
          ),
        ).thenReturn([word1]);

        final results = await searchRepository.search('test');

        expect(results.length, equals(1));
      });
    });
  });
}
