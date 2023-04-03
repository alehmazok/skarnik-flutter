import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:skarnik_flutter/app_config.dart';

@Singleton(as: Dio)
class SkarnikDio extends DioForNative {
  SkarnikDio() : super() {
    _overrideBadCertificateBehavior();
    _initInterceptors();
  }

  // TODO: Часовы фікс. На старых дэвайсах (sdk 21) не працуюць ssl запыты, таму адключаем праверку ўвогуле.
  void _overrideBadCertificateBehavior() {
    (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      return client..badCertificateCallback = (cert, host, port) => true;
    };
  }

  void _initInterceptors() {
    interceptors.addAll([
      DioCacheManager(CacheConfig(baseUrl: AppConfig.host)).interceptor,
      if (kDebugMode)
        // TODO: вынесцi кудысьцi
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: false,
        ),
    ]);
  }
}
