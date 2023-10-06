import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:html/parser.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/entity/translation.dart';
import '../../domain/repository/translation_repository.dart';

@Injectable(as: FallbackTranslationRepository)
class SkarnikTranslationRepository implements FallbackTranslationRepository {
  final _logger = getLogger(SkarnikTranslationRepository);
  final Dio _dio;

  late final Word _word;
  late Uri _uri;

  SkarnikTranslationRepository(this._dio);

  @override
  Future<Translation> getTranslation(Word word) async {
    _word = word;
    _setUri(word.wordId);

    return _fetch();
  }

  _setUri(int wordId) {
    _uri = Uri(
      scheme: 'https',
      host: AppConfig.skarnikSiteHostName,
      pathSegments: [_word.dictPath, '$wordId'],
    );
  }

  Translation _buildTranslation(String html) => Translation.build(
        uri: _uri,
        word: _word,
        html: html,
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
      return _buildTranslation(trn.outerHtml);
    } else if (rdr != null) {
      _setUri(_word.wordId + 1);

      return await _fetch();
    }

    throw StateError('Памылка перакладу слова (id=${_word.wordId}).');
  }
}
