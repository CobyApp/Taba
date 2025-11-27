import 'package:flutter/foundation.dart';

/// API 환경 설정
enum ApiEnvironment {
  development,
  production,
}

class ApiConfig {
  // 환경 설정
  // 우선순위: 1) --dart-define=API_ENV, 2) 빌드 모드 (Release = 프로덕션, Debug/Profile = 개발)
  static ApiEnvironment get environment {
    // --dart-define로 환경을 명시적으로 지정한 경우 우선 사용
    const String envFromDefine = String.fromEnvironment('API_ENV', defaultValue: '');
    if (envFromDefine.isNotEmpty) {
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
    // Release 모드 = 프로덕션 환경 (항상)
    // Debug/Profile 모드 = 개발 환경
    if (kReleaseMode) {
      // Release 빌드는 항상 프로덕션 서버 사용
      return ApiEnvironment.production;
    } else {
      // Debug 또는 Profile 빌드는 개발 서버 사용
      return ApiEnvironment.development;
    }
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
