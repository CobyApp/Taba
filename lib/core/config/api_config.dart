import 'package:flutter/foundation.dart';

/// API 환경 설정
enum ApiEnvironment {
  development,
  production,
}

class ApiConfig {
  // 환경 설정 (기본값: Debug 모드면 개발, Release 모드면 프로덕션)
  static ApiEnvironment get environment {
    // --dart-define로 환경을 명시적으로 지정한 경우 우선 사용
    const String? envFromDefine = String.fromEnvironment('API_ENV', defaultValue: null);
    if (envFromDefine != null) {
      switch (envFromDefine.toLowerCase()) {
        case 'dev':
        case 'development':
          return ApiEnvironment.development;
        case 'prod':
        case 'production':
          return ApiEnvironment.production;
        default:
          break;
      }
    }
    
    // 명시적 지정이 없으면 빌드 모드로 판단
    // Debug 모드 = 개발 환경, Release 모드 = 프로덕션 환경
    return kDebugMode ? ApiEnvironment.development : ApiEnvironment.production;
  }

  // Base URL 설정
  static String get baseUrl {
    switch (environment) {
      case ApiEnvironment.development:
        return 'https://dev.taba.asia';
      case ApiEnvironment.production:
        return 'https://www.taba.asia';
    }
  }

  static const String apiVersion = 'v1';
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  
  // 현재 환경 정보 (디버깅용)
  static String get environmentName {
    switch (environment) {
      case ApiEnvironment.development:
        return 'Development';
      case ApiEnvironment.production:
        return 'Production';
    }
  }
  
  // Timeout 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const String contentType = 'application/json';
  static const String charset = 'UTF-8';
}
