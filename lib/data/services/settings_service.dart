import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<bool>> getPushNotificationSetting() async {
    try {
      final response =
          await _apiClient.dio.get('/settings/push-notification');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<bool>(
          success: false,
          error: ApiError(
            code: 'GET_PUSH_SETTING_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<bool>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['enabled'] as bool,
      );
    } on DioException catch (e) {
      String errorMessage = '푸시 알림 설정을 불러오는데 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<bool>(
        success: false,
        error: ApiError(
          code: 'GET_PUSH_SETTING_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        error: ApiError(
          code: 'GET_PUSH_SETTING_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<bool>> updatePushNotificationSetting(bool enabled) async {
    try {
      final response = await _apiClient.dio.put(
        '/settings/push-notification',
        data: {'enabled': enabled},
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<bool>(
          success: false,
          error: ApiError(
            code: 'UPDATE_PUSH_SETTING_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<bool>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['enabled'] as bool,
      );
    } on DioException catch (e) {
      String errorMessage = '푸시 알림 설정 변경에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<bool>(
        success: false,
        error: ApiError(
          code: 'UPDATE_PUSH_SETTING_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        error: ApiError(
          code: 'UPDATE_PUSH_SETTING_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<String>> getLanguageSetting() async {
    try {
      final response = await _apiClient.dio.get('/settings/language');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<String>(
          success: false,
          error: ApiError(
            code: 'GET_LANGUAGE_SETTING_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['language'] as String,
      );
    } on DioException catch (e) {
      String errorMessage = '언어 설정을 불러오는데 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'GET_LANGUAGE_SETTING_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'GET_LANGUAGE_SETTING_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<String>> updateLanguageSetting(String language) async {
    try {
      final response = await _apiClient.dio.put(
        '/settings/language',
        data: {'language': language},
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<String>(
          success: false,
          error: ApiError(
            code: 'UPDATE_LANGUAGE_SETTING_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['language'] as String,
      );
    } on DioException catch (e) {
      String errorMessage = '언어 설정 변경에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UPDATE_LANGUAGE_SETTING_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UPDATE_LANGUAGE_SETTING_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }
}

