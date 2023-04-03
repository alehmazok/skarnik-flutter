import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/entity/translation.dart';
import '../../domain/repository/translation_repository.dart';

@Injectable(as: TranslationRepository)
class SkarnikTranslationRepository implements TranslationRepository {
  static const _host = AppConfig.host;
  final _logger = getLogger(SkarnikTranslationRepository);
  final _dio = Dio()
    ..interceptors.addAll([
      DioCacheManager(CacheConfig(baseUrl: _host)).interceptor,
      if (kDebugMode)
        // TODO: вынесцi кудысьцi
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: false,
        ),
    ]);

  late final Word _word;
  late Uri _uri;

  @override
  Future<Translation> getTranslation(Word word) async {
    _word = word;
    _setUri(word.wordId);

    return _fetch();
  }

  _setUri(int wordId) {
    _uri = Uri(
      scheme: 'https',
      host: _host,
      pathSegments: [_word.dictPath, '$wordId'],
    );
  }

  Translation _buildTranslation(String html) => Translation(
        uri: _uri,
        word: _word,
        // TODO: вынесці логіку мадыфікацыі тэксту і html ў іншы юскейс.
        html: html.replaceAll(RegExp('color="#?'), 'color="#'),
      );

  Future<Translation> _fetch() async {
    _logger.fine('Робім запыт на: ${_uri.toString()}');
    final res = await _dio.getUri<List<int>>(
      _uri,
      options: buildCacheOptions(
        Duration(hours: FirebaseRemoteConfig.instance.getInt(AppConfig.httpCacheDurationInHours)),
        options: Options(
          contentType: Headers.textPlainContentType,
          responseType: ResponseType.bytes,
        ),
      ),
    );

    return await _parse(res.data!);
  }

  /// Магія. Шукаем патрэбныя тэгі на старонцы Скарніка.
  /// Калі няма кантэнту ў адным, шукаем у іншым, калі і там няма - памылка.
  Future<Translation> _parse(List<int> bytes) async {
    final document = parse(bytes);
    final tgt = document.querySelector('div#tgt');
    final trn = tgt?.querySelector('p#trn');
    final rdr = tgt?.querySelector('p#rdr');
    if (trn != null) {
      final divWrapper = Element.tag('div')
        ..append(trn)
        ..id = 'skarnik';

      return _buildTranslation(divWrapper.outerHtml);
    } else if (rdr != null) {
      _setUri(_word.wordId + 1);

      return await _fetch();
    }

    throw StateError('Памылка перакладу слова (id=${_word.wordId}).');
  }
}
