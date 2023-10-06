import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@Singleton(as: Dio)
class SkarnikDio extends DioForNative {
  SkarnikDio() : super() {
    _initInterceptors();
  }

  void _initInterceptors() {
    interceptors.addAll([
      DioCacheManager(CacheConfig()).interceptor,
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: false,
        ),
    ]);
  }
}
