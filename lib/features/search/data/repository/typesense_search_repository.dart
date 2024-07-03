import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:typesense/typesense.dart';

import '../../domain/repository/search_repository.dart';
import '../model/search_hit_word.dart';

@LazySingleton(as: SearchRepository)
class TypesenseSearchRepository implements SearchRepository {
  static const letterSubstitutions = {
    'и': 'і',
    'е': 'ё',
    'щ': 'ў',
    'ъ': '‘',
    '\'': '‘',
  };

  static final _config = Configuration(
    // Api key
    AppConfig.typesenseApiKey,
    nodes: {
      Node.withUri(
        Uri(
          scheme: 'https',
          host: AppConfig.typesenseHostName,
          port: 443,
        ),
      ),
    },
    numRetries: 3, // A total of 4 tries (1 original try + 3 retries)
    connectionTimeout: const Duration(seconds: 2),
  );

  final client = Client(_config);

  @override
  Future<Iterable<Word>> search(String searchQuery) async {
    final q = searchQuery;
    final collection = client.collection('words');
    debugPrint('Searching for `$q`...');
    final searchParameters = {
      'q': q.toLowerCase(),
      'query_by': 'lword,lwordMask',
      // 'filter_by': 'num_employees:>100',
      // 'sort_by': 'word:desc'
      'limit': '20',
    };
    final result = await collection.documents.search(searchParameters);
    debugPrint('=== Results ===');
    debugPrint(result.toString());
    final hits = result['hits'] as List;
    final words = hits.map((it) => SearchHitWord.fromMap(it).toEntity());
    return words;
  }

  bool isSearchByMaskApplicable(String query) => query.length >= 3;

  String applySubstitutions(String query) {
    for (final entry in letterSubstitutions.entries) {
      query = query.replaceAll(entry.key, entry.value);
    }
    return query;
  }
}
