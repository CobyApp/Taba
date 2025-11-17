import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<bool>> getPushNotificationSetting() async {
    try {
      final response =
          await _apiClient.dio.get('/settings/push-notification');

      return ApiResponse<bool>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['enabled'] as bool,
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        error: ApiError(
          code: 'GET_PUSH_SETTING_ERROR',
          message: e.toString(),
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

      return ApiResponse<bool>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['enabled'] as bool,
      );
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        error: ApiError(
          code: 'UPDATE_PUSH_SETTING_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<String>> getLanguageSetting() async {
    try {
      final response = await _apiClient.dio.get('/settings/language');

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['language'] as String,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'GET_LANGUAGE_SETTING_ERROR',
          message: e.toString(),
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

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['language'] as String,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UPDATE_LANGUAGE_SETTING_ERROR',
          message: e.toString(),
        ),
      );
    }
  }
}

