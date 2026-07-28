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
        () => queryRepository.fuzzySearch(
          firstLetter: any(named: 'firstLetter'),
          searchQuery: any(named: 'searchQuery'),
          maxDistance: any(named: 'maxDistance'),
          resultLimit: any(named: 'resultLimit'),
          excluded: any(named: 'excluded'),
        ),
      ).thenAnswer((_) async => []);
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

        expect(results.words.length, equals(1));
        expect(results.words, contains(word1));
        expect(results.usedPrepositionFallback, isFalse);
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

        expect(results.words.length, equals(2));
        expect(results.words, containsAll([word1, word2]));
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

        expect(results.words.length, equals(1));
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

        expect(results.words, isEmpty);
        expect(results.usedPrepositionFallback, isFalse);
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

        expect(results.words.toList(), equals([word1, word2]));
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

    group('fuzzy search', () {
      test(
        'does not call fuzzySearch when there is at least one exact/mask result',
        () async {
          final word1 = _makeWord();
          stubExact(byWord: [word1], byWordMask: []);

          await searchRepository.search('test');

          verifyNever(
            () => queryRepository.fuzzySearch(
              firstLetter: any(named: 'firstLetter'),
              searchQuery: any(named: 'searchQuery'),
              maxDistance: any(named: 'maxDistance'),
              resultLimit: any(named: 'resultLimit'),
              excluded: any(named: 'excluded'),
            ),
          );
        },
      );

      test('calls fuzzySearch when there are zero exact/mask results', () async {
        stubExact(byWord: [], byWordMask: []);

        await searchRepository.search('test');

        verify(
          () => queryRepository.fuzzySearch(
            firstLetter: 't',
            searchQuery: 'test',
            maxDistance: 1,
            resultLimit: 15,
            excluded: any(named: 'excluded'),
          ),
        ).called(1);
      });

      test('does not call fuzzySearch for short queries even when sparse', () async {
        stubExact(byWord: [], byWordMask: []);

        await searchRepository.search('ab');

        verifyNever(
          () => queryRepository.fuzzySearch(
            firstLetter: any(named: 'firstLetter'),
            searchQuery: any(named: 'searchQuery'),
            maxDistance: any(named: 'maxDistance'),
            resultLimit: any(named: 'resultLimit'),
            excluded: any(named: 'excluded'),
          ),
        );
      });

      test('queries the letter-substituted first letter, not the raw one', () async {
        // 'и' -> 'і' via applySubstitutions(); fuzzy should bucket on 'і'.
        stubExact(byWord: [], byWordMask: []);

        await searchRepository.search('иии');

        verify(
          () => queryRepository.fuzzySearch(
            firstLetter: 'і',
            searchQuery: 'ііі',
            maxDistance: 1,
            resultLimit: 15,
            excluded: any(named: 'excluded'),
          ),
        ).called(1);
      });

      test('returns fuzzy matches when exact and mask stages find nothing', () async {
        final fuzzyWord = _makeWord(id: 3, wordId: 3, word: 'tost');
        stubExact(byWord: [], byWordMask: []);
        when(
          () => queryRepository.fuzzySearch(
            firstLetter: 't',
            searchQuery: 'test',
            maxDistance: 1,
            resultLimit: 15,
            excluded: any(named: 'excluded'),
          ),
        ).thenAnswer((_) async => [fuzzyWord]);

        final results = await searchRepository.search('test');

        expect(results.words.toList(), equals([fuzzyWord]));
        expect(results.usedPrepositionFallback, isFalse);
      });
    });

    group('glued preposition fallback', () {
      test(
        'retries with stripped query and finds a fuzzy match when primary pass is fully empty',
        () async {
          // applySubstitutions() turns trailing 'е' into 'ё' in both the raw
          // and stripped queries ('всмысле' -> 'всмыслё', 'смысле' -> 'смыслё').
          final smyslWord = _makeWord(id: 4, wordId: 4, letter: 'с', word: 'смысл');
          when(
            () => queryRepository.queryByWord(
              searchQuery: 'всмысле',
              searchQueryWithSubstitutions: 'всмыслё',
            ),
          ).thenReturn([]);
          when(
            () => queryRepository.queryByWordMask(
              searchQuery: 'всмысле',
              searchQueryWithSubstitutions: 'всмыслё',
              excluded: [],
            ),
          ).thenReturn([]);
          when(
            () => queryRepository.fuzzySearch(
              firstLetter: 'в',
              searchQuery: 'всмыслё',
              maxDistance: 2,
              resultLimit: 15,
              excluded: any(named: 'excluded'),
            ),
          ).thenAnswer((_) async => []);

          when(
            () => queryRepository.queryByWord(
              searchQuery: 'смысле',
              searchQueryWithSubstitutions: 'смыслё',
            ),
          ).thenReturn([]);
          when(
            () => queryRepository.queryByWordMask(
              searchQuery: 'смысле',
              searchQueryWithSubstitutions: 'смыслё',
              excluded: [],
            ),
          ).thenReturn([]);
          when(
            () => queryRepository.fuzzySearch(
              firstLetter: 'с',
              searchQuery: 'смыслё',
              maxDistance: 2,
              resultLimit: 15,
              excluded: any(named: 'excluded'),
            ),
          ).thenAnswer((_) async => [smyslWord]);

          final results = await searchRepository.search('всмысле');

          expect(results.words.toList(), equals([smyslWord]));
          expect(results.usedPrepositionFallback, isTrue);
        },
      );

      test('does not retry when query does not start with a glued-prefix letter', () async {
        stubExact(byWord: [], byWordMask: []);

        await searchRepository.search('тест');

        verifyNever(
          () => queryRepository.queryByWord(
            searchQuery: 'ест',
            searchQueryWithSubstitutions: any(named: 'searchQueryWithSubstitutions'),
          ),
        );
      });

      test('does not retry when the primary pass already found results', () async {
        final word1 = _makeWord();
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'всмысле',
            searchQueryWithSubstitutions: 'всмыслё',
          ),
        ).thenReturn([word1]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'всмысле',
            searchQueryWithSubstitutions: 'всмыслё',
            excluded: [word1],
          ),
        ).thenReturn([]);

        final results = await searchRepository.search('всмысле');

        expect(results.usedPrepositionFallback, isFalse);
        verify(
          () => queryRepository.queryByWord(
            searchQuery: 'всмысле',
            searchQueryWithSubstitutions: 'всмыслё',
          ),
        ).called(1);
        verifyNever(
          () => queryRepository.queryByWord(
            searchQuery: 'смысле',
            searchQueryWithSubstitutions: any(named: 'searchQueryWithSubstitutions'),
          ),
        );
      });

      test('does not strip a single-character query', () async {
        stubExact(byWord: [], byWordMask: []);

        await searchRepository.search('в');

        verifyNever(
          () => queryRepository.queryByWord(
            searchQuery: '',
            searchQueryWithSubstitutions: any(named: 'searchQueryWithSubstitutions'),
          ),
        );
      });

      test('strips a Belarusian one-letter conjunction (і)', () async {
        final ranakWord = _makeWord(id: 5, wordId: 5, letter: 'р', word: 'ранак');
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'іранак',
            searchQueryWithSubstitutions: 'іранак',
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'іранак',
            searchQueryWithSubstitutions: 'іранак',
            excluded: [],
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.fuzzySearch(
            firstLetter: 'і',
            searchQuery: 'іранак',
            maxDistance: 2,
            resultLimit: 15,
            excluded: any(named: 'excluded'),
          ),
        ).thenAnswer((_) async => []);

        when(
          () => queryRepository.queryByWord(
            searchQuery: 'ранак',
            searchQueryWithSubstitutions: 'ранак',
          ),
        ).thenReturn([ranakWord]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'ранак',
            searchQueryWithSubstitutions: 'ранак',
            excluded: [ranakWord],
          ),
        ).thenReturn([]);

        final results = await searchRepository.search('іранак');

        expect(results.words.toList(), equals([ranakWord]));
        expect(results.usedPrepositionFallback, isTrue);
      });

      // The following cases are real `search_no_results` queries (BigQuery,
      // 2026-06-01..2026-07-28), each cross-checked against the production
      // dictionary (Supabase `main_word`) to confirm the stripped query is a
      // real prefix/exact match. Unlike the 'всмысле' case, these resolve via
      // the exact/mask stage on the retry, without needing fuzzy search.

      test('strips glued "у" and finds an exact prefix match (узгадва -> згадва)', () async {
        final zgadvatsWord = _makeWord(id: 6, wordId: 6, letter: 'з', word: 'згадваць');
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'узгадва',
            searchQueryWithSubstitutions: 'узгадва',
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'узгадва',
            searchQueryWithSubstitutions: 'узгадва',
            excluded: [],
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.fuzzySearch(
            firstLetter: 'у',
            searchQuery: 'узгадва',
            maxDistance: 2,
            resultLimit: 15,
            excluded: any(named: 'excluded'),
          ),
        ).thenAnswer((_) async => []);

        when(
          () => queryRepository.queryByWord(
            searchQuery: 'згадва',
            searchQueryWithSubstitutions: 'згадва',
          ),
        ).thenReturn([zgadvatsWord]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'згадва',
            searchQueryWithSubstitutions: 'згадва',
            excluded: [zgadvatsWord],
          ),
        ).thenReturn([]);

        final results = await searchRepository.search('узгадва');

        expect(results.words.toList(), equals([zgadvatsWord]));
        expect(results.usedPrepositionFallback, isTrue);
      });

      test(
        'strips glued "у" and finds an exact match (ураўніннасць -> раўніннасць)',
        () async {
          final raunninnascWord = _makeWord(
            id: 8,
            wordId: 8,
            letter: 'р',
            word: 'раўніннасць',
          );
          when(
            () => queryRepository.queryByWord(
              searchQuery: 'ураўніннасць',
              searchQueryWithSubstitutions: 'ураўніннасць',
            ),
          ).thenReturn([]);
          when(
            () => queryRepository.queryByWordMask(
              searchQuery: 'ураўніннасць',
              searchQueryWithSubstitutions: 'ураўніннасць',
              excluded: [],
            ),
          ).thenReturn([]);
          when(
            () => queryRepository.fuzzySearch(
              firstLetter: 'у',
              searchQuery: 'ураўніннасць',
              maxDistance: 2,
              resultLimit: 15,
              excluded: any(named: 'excluded'),
            ),
          ).thenAnswer((_) async => []);

          when(
            () => queryRepository.queryByWord(
              searchQuery: 'раўніннасць',
              searchQueryWithSubstitutions: 'раўніннасць',
            ),
          ).thenReturn([raunninnascWord]);
          when(
            () => queryRepository.queryByWordMask(
              searchQuery: 'раўніннасць',
              searchQueryWithSubstitutions: 'раўніннасць',
              excluded: [raunninnascWord],
            ),
          ).thenReturn([]);

          final results = await searchRepository.search('ураўніннасць');

          expect(results.words.toList(), equals([raunninnascWord]));
          expect(results.usedPrepositionFallback, isTrue);
        },
      );

      test('strips glued "у" and finds an exact prefix match (усціш -> сціш)', () async {
        final stsishWord = _makeWord(id: 9, wordId: 9, letter: 'с', word: 'сцішаны');
        when(
          () => queryRepository.queryByWord(
            searchQuery: 'усціш',
            searchQueryWithSubstitutions: 'усціш',
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'усціш',
            searchQueryWithSubstitutions: 'усціш',
            excluded: [],
          ),
        ).thenReturn([]);
        when(
          () => queryRepository.fuzzySearch(
            firstLetter: 'у',
            searchQuery: 'усціш',
            maxDistance: 1,
            resultLimit: 15,
            excluded: any(named: 'excluded'),
          ),
        ).thenAnswer((_) async => []);

        when(
          () => queryRepository.queryByWord(
            searchQuery: 'сціш',
            searchQueryWithSubstitutions: 'сціш',
          ),
        ).thenReturn([stsishWord]);
        when(
          () => queryRepository.queryByWordMask(
            searchQuery: 'сціш',
            searchQueryWithSubstitutions: 'сціш',
            excluded: [stsishWord],
          ),
        ).thenReturn([]);

        final results = await searchRepository.search('усціш');

        expect(results.words.toList(), equals([stsishWord]));
        expect(results.usedPrepositionFallback, isTrue);
      });

      test('retry itself can return nothing (double miss stays empty)', () async {
        stubExact(byWord: [], byWordMask: []);

        final results = await searchRepository.search('всмысле');

        expect(results.words, isEmpty);
        expect(results.usedPrepositionFallback, isTrue);
      });
    });
  });
}
