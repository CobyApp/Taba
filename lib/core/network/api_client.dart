import 'package:dio/dio.dart';
import 'package:taba_app/core/config/api_config.dart';
import 'package:taba_app/core/storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();
  bool _tokenPrinted = false; // 토큰 출력 여부 추적

  ApiClient() {
    // 환경 정보 출력 (디버깅용)
    print('🌍 API Environment: ${ApiConfig.environmentName}');
    print('🔗 API Base URL: ${ApiConfig.apiBaseUrl}');
    
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
          // Health check 엔드포인트는 인증 불필요
          final path = options.path.toLowerCase();
          if (path.contains('/actuator/health') || 
              path.contains('/health') ||
              path.contains('/actuator/info')) {
            return handler.next(options);
          }
          
          // 토큰 자동 추가
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            
            // Swagger 테스트용 토큰 출력 (첫 번째 요청 시에만)
            if (!_tokenPrinted) {
              print('🔑 Bearer Token for Swagger:');
              print('   $token');
              print('   (Copy this token to use in Swagger Authorization)');
              _tokenPrinted = true;
            }
          } else {
            print('⚠️ No token found. Please login first.');
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // 에러 발생 시 API 엔드포인트 정보 로깅
          final requestOptions = error.requestOptions;
          final method = requestOptions.method;
          final fullUrl = requestOptions.uri.toString();
          final statusCode = error.response?.statusCode;
          
          print('❌ API Error: $method $fullUrl');
          print('   Status Code: ${statusCode ?? 'N/A'}');
          if (error.response?.data != null) {
            print('   Response Data: ${error.response!.data}');
            
            // API 명세서에 따른 에러 응답 구조 파싱
            try {
              final errorData = error.response!.data as Map<String, dynamic>;
              if (errorData.containsKey('success') && errorData['success'] == false) {
                final errorObj = errorData['error'] as Map<String, dynamic>?;
                if (errorObj != null) {
                  print('   Error Code: ${errorObj['code']}');
                  print('   Error Message: ${errorObj['message']}');
                }
              }
            } catch (e) {
              // 파싱 실패 시 무시
            }
          }
          if (error.message != null) {
            print('   Error Message: ${error.message}');
          }
          
          // 401 에러 시 토큰 제거
          if (error.response?.statusCode == 401) {
            _tokenStorage.clearToken();
            // 로그는 출력하지 않음 (정상적인 인증 실패일 수 있음)
          }
          
          // 에러 응답을 ApiResponse 형식으로 변환
          // API 명세서에 따르면 { success: false, error: { code, message } } 형식
          if (error.response?.data != null) {
            try {
              final errorData = error.response!.data as Map<String, dynamic>;
              // API 명세서 에러 응답 형식 처리
              if (errorData.containsKey('success') && errorData['success'] == false) {
                // 이미 올바른 형식이므로 그대로 전달
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
  
  // Swagger 테스트용 토큰 출력 메서드
  Future<void> printTokenForSwagger() async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      print('🔑 Bearer Token for Swagger:');
      print('   $token');
      print('   (Copy this token to use in Swagger Authorization)');
    } else {
      print('⚠️ No token found. Please login first.');
    }
  }
}
