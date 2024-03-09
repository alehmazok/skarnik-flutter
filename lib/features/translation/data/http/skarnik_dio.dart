import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@LazySingleton(as: Dio)
class SkarnikDio extends DioForNative implements Dio {
  SkarnikDio() : super() {
    _overrideBadCertificateBehavior();
    _initInterceptors();
  }

  Future<void> _overrideBadCertificateBehavior() async {
    if (!Platform.isAndroid) {
      return;
    }
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt < 26) {
      (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        return client..badCertificateCallback = (cert, host, port) => true;
      };
    }
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
