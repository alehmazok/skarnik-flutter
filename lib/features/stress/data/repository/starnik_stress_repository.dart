import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:html/parser.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/entity/stress_row.dart';
import '../../domain/entity/stress_source.dart';
import '../../domain/entity/stress_word_entry.dart';
import '../../domain/repository/stress_repository.dart';

@Injectable(as: StressRepository)
class StarnikStressRepository implements StressRepository {
  final _logger = getLogger(StarnikStressRepository);
  final Dio _dio;

  StarnikStressRepository(this._dio);

  static const _baseUrl = 'https://${AppConfig.starnikSiteHostName}';

  @override
  Future<List<StressWordEntry>> resolveWordList(String word) async {
    _logger.fine('Resolving word list for: $word');
    final response = await _dio.get<dynamic>(
      '$_baseUrl/api/wordList',
      queryParameters: {'lemma': word},
      options: buildCacheOptions(
        Duration(hours: FirebaseRemoteConfig.instance.getInt(AppConfig.httpCacheDurationInHours)),
        options: Options(responseType: ResponseType.json),
      ),
    );
    final data = response.data as Map<String, dynamic>;
    final wordList = data['word_list'] as List<dynamic>;
    return wordList
        .map(
          (item) => StressWordEntry(
            id: item['id'] as int,
            lemma: item['lemma'] as String,
            word: item['word'] as String,
            tableName: item['table_name'] as String?,
            source: StressSource.api,
          ),
        )
        .toList();
  }

  @override
  Future<List<StressRow>> getStressTable(int wordId) async {
    _logger.fine('Fetching stress table for wordId: $wordId');
    final response = await _dio.get<String>(
      '$_baseUrl/pravapis/$wordId',
      options: buildCacheOptions(
        Duration(hours: FirebaseRemoteConfig.instance.getInt(AppConfig.httpCacheDurationInHours)),
        options: Options(
          responseType: ResponseType.plain,
        ),
      ),
    );
    return _parseTable(response.data!);
  }

  List<StressRow> _parseTable(String html) {
    final document = parse(html);
    final table = document.querySelector('.wrapper table');
    if (table == null) return const [];
    final rows = <StressRow>[];
    for (final tr in table.querySelectorAll('tr')) {
      final tds = tr.querySelectorAll('td');
      if (tds.length != 2) continue;
      rows.add(StressRow(title: tds[0].innerHtml, content: tds[1].innerHtml));
    }
    return rows;
  }
}
