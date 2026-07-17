import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/app_config.dart';
import 'package:skarnik_flutter/logging.dart';

import '../../domain/entity/stress_row.dart';
import '../../domain/entity/stress_word_entry.dart';
import '../../domain/repository/cloud_stress_repository.dart';
import '../model/cloud_stress_word_model.dart';

@LazySingleton(as: CloudStressRepository)
class ApiStressRepositoryImpl implements CloudStressRepository {
  final _logger = getLogger(ApiStressRepositoryImpl);

  final Dio _dio;

  ApiStressRepositoryImpl(this._dio);

  static const _baseUrl = AppConfig.apiHostName;

  @override
  Future<List<StressWordEntry>> resolveWordList(String word) async {
    final uri = Uri.parse('$_baseUrl/api/stress_words/').replace(
      queryParameters: {'word': word.toLowerCase()},
    );

    _logger.fine('Робім запыт на: ${uri.toString()}');

    final res = await _dio.getUri(
      uri,
      options: buildCacheOptions(
        Duration(hours: FirebaseRemoteConfig.instance.getInt(AppConfig.httpCacheDurationInHours)),
      ),
    );
    final list = res.data as List<dynamic>;

    return list
        .map((json) => CloudStressWordModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<StressRow>> getStressTable(int wordId) async {
    final uri = Uri.parse('$_baseUrl/api/stress_words/$wordId/');

    _logger.fine('Робім запыт на: ${uri.toString()}');

    final res = await _dio.getUri(
      uri,
      options: buildCacheOptions(
        Duration(hours: FirebaseRemoteConfig.instance.getInt(AppConfig.httpCacheDurationInHours)),
      ),
    );
    final data = res.data as Map<String, dynamic>;

    return CloudStressWordModel.fromJson(data).toRows();
  }
}
