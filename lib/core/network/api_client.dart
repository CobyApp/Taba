import 'package:dio/dio.dart';
import 'package:taba_app/core/config/api_config.dart';
import 'package:taba_app/core/storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': ApiConfig.contentType,
          'Charset': ApiConfig.charset,
        },
      ),
    );

    // Interceptor 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 토큰 자동 추가
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // 401 에러 시 토큰 제거 및 로그아웃 처리
          if (error.response?.statusCode == 401) {
            _tokenStorage.clearToken();
            // 로그아웃 이벤트 발생 (나중에 구현)
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
