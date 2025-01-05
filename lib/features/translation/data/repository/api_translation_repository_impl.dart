import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/entity/api_word.dart';
import '../../domain/repository/api_translation_repository.dart';
import '../model/api_word_model.dart';

@LazySingleton(as: ApiTranslationRepository)
class ApiTranslationRepositoryImpl implements ApiTranslationRepository {
  final _logger = getLogger(ApiTranslationRepositoryImpl);

  final Dio _dio;

  ApiTranslationRepositoryImpl(this._dio);

  @override
  Future<ApiWord> getTranslation(Word word) async {
    final uri = word.buildApiUri();

    _logger.fine('Робім запыт на: ${uri.toString()}');

    final res = await _dio.getUri(
      uri,
      options: buildCacheOptions(
        Duration(hours: FirebaseRemoteConfig.instance.getInt(AppConfig.httpCacheDurationInHours)),
      ),
    );
    final data = res.data as Map<String, dynamic>;

    final model = ApiWordModel.fromJson(data);

    return model.toEntity();
  }
}
