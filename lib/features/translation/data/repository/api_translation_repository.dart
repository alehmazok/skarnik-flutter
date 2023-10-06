import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

import '../../domain/entity/api_word.dart';
import '../../domain/entity/translation.dart';
import '../../domain/repository/translation_repository.dart';

@Injectable(as: PrimaryTranslationRepository)
class ApiTranslationRepository implements PrimaryTranslationRepository {
  final Dio _dio;

  ApiTranslationRepository(this._dio);

  @override
  Future<Translation> getTranslation(Word word) async {
    final uri = Uri.https(
      AppConfig.apiHostName,
      'api/words/',
      {
        'external_id': '${word.wordId}',
      },
    );

    final res = await _dio.getUri(
      uri,
      options: buildCacheOptions(
        Duration(hours: FirebaseRemoteConfig.instance.getInt(AppConfig.httpCacheDurationInHours)),
      ),
    );

    final apiWord = ApiWord.fromJson(res.data as Map<String, dynamic>);
    return Translation.build(
      uri: uri,
      word: word,
      html: apiWord.translation,
    );
  }
}
