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
          // 401 에러 시 토큰 제거
          if (error.response?.statusCode == 401) {
            _tokenStorage.clearToken();
            // 로그는 출력하지 않음 (정상적인 인증 실패일 수 있음)
          }
          
          // 에러 응답을 ApiResponse 형식으로 변환
          if (error.response?.data != null) {
            try {
              final errorData = error.response!.data as Map<String, dynamic>;
              // Spring Boot 에러 응답 형식 처리
              if (errorData.containsKey('error') || errorData.containsKey('message')) {
                return handler.next(error);
              }
            } catch (e) {
              // 파싱 실패 시 그대로 전달
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
