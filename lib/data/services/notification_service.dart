import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/notification_dto.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ApiResponse<PageResponse<NotificationDto>>> getNotifications({
    int page = 0,
    int size = 20,
    String? category,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'size': size,
          if (category != null) 'category': category,
        },
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<PageResponse<NotificationDto>>(
          success: false,
          error: ApiError(
            code: 'GET_NOTIFICATIONS_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<PageResponse<NotificationDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageResponse<NotificationDto>.fromJson(
          data as Map<String, dynamic>,
          (item) =>
              NotificationDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      String errorMessage = '알림 목록을 불러오는데 실패했습니다.';
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
      
      return ApiResponse<PageResponse<NotificationDto>>(
        success: false,
        error: ApiError(
          code: 'GET_NOTIFICATIONS_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<PageResponse<NotificationDto>>(
        success: false,
        error: ApiError(
          code: 'GET_NOTIFICATIONS_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<NotificationDto>> markAsRead(String notificationId) async {
    try {
      // API 명세서: PATCH /notifications/{notificationId}/read
      final response =
          await _apiClient.dio.patch('/notifications/$notificationId/read');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<NotificationDto>(
          success: false,
          error: ApiError(
            code: 'MARK_NOTIFICATION_READ_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<NotificationDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => NotificationDto.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      String errorMessage = '알림 읽음 처리에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '알림을 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<NotificationDto>(
        success: false,
        error: ApiError(
          code: 'MARK_NOTIFICATION_READ_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<NotificationDto>(
        success: false,
        error: ApiError(
          code: 'MARK_NOTIFICATION_READ_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.put('/notifications/read-all');

      // API 명세서에 따르면 응답: {success: true, data: {readCount: 5, message: "..."}}
      // readCount 정보는 사용하지 않으므로 void로 처리
      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } on DioException catch (e) {
      String errorMessage = '전체 알림 읽음 처리에 실패했습니다.';
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
      
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'MARK_ALL_READ_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'MARK_ALL_READ_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<void>> deleteNotification(String notificationId) async {
    try {
      final response =
          await _apiClient.dio.delete('/notifications/$notificationId');

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } on DioException catch (e) {
      String errorMessage = '알림 삭제에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '알림을 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'DELETE_NOTIFICATION_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'DELETE_NOTIFICATION_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }
}

