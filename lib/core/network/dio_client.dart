import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';

class DioClient {
  final Dio _dio;

  DioClient({
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.nodeBackendBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: kIsWeb ? null : const Duration(seconds: 10),
                headers: <String, dynamic>{
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.addAll(
      <Interceptor>[
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      ],
    );
  }

  Dio get instance => _dio;
}
