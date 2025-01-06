import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/data/model/objectbox_search_word.dart';
import 'package:skarnik_flutter/features/app/domain/entity/search_word.dart';
import 'package:skarnik_flutter/features/search/data/repository/objectbox_search_repository.dart';
import 'package:skarnik_flutter/features/search/domain/repository/query_repository.dart';
import 'package:test/test.dart';

class MockQueryRepository extends Mock implements QueryRepository {}

class MockSearchWord extends Mock implements SearchWord {}

void main() {
  group('ObjectboxSearchRepository', () {
    test('search() method returns only one result', () async {
      // word1 and word2 are different instances, but equal by value
      final word1 = ObjectboxSearchWord(
        langId: 1,
        letter: 'a',
        wordId: 1,
        word: 'aaa',
        lword: 'aaa',
        lwordMask: 'aaa',
      );
      final word2 = ObjectboxSearchWord(
        langId: 1,
        letter: 'a',
        wordId: 1,
        word: 'aaa',
        lword: 'aaa',
        lwordMask: 'aaa',
      );

      final queryRepository = MockQueryRepository();
      when(
        () => queryRepository.queryByWord(
          searchQuery: 'test',
          searchQueryWithSubstitutions: 'test',
        ),
      ).thenReturn(
        [word1],
      );
      when(
        () => queryRepository.queryByWordMask(
          searchQuery: 'test',
          searchQueryWithSubstitutions: 'test',
          excluded: [word1],
        ),
      ).thenReturn(
        [word2],
      );

      final searchRepository = ObjectboxSearchRepository(queryRepository);
      final results = await searchRepository.search('test');
      expect(results.length, equals(1));
    });
  });
}
