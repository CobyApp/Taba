import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/notification_dto.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

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

      return ApiResponse<PageResponse<NotificationDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageResponse<NotificationDto>.fromJson(
          data as Map<String, dynamic>,
          (item) =>
              NotificationDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      return ApiResponse<PageResponse<NotificationDto>>(
        success: false,
        error: ApiError(
          code: 'GET_NOTIFICATIONS_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<NotificationDto>> markAsRead(String notificationId) async {
    try {
      final response =
          await _apiClient.dio.put('/notifications/$notificationId/read');

      return ApiResponse<NotificationDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => NotificationDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<NotificationDto>(
        success: false,
        error: ApiError(
          code: 'MARK_NOTIFICATION_READ_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.put('/notifications/read-all');

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'MARK_ALL_READ_ERROR',
          message: e.toString(),
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
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'DELETE_NOTIFICATION_ERROR',
          message: e.toString(),
        ),
      );
    }
  }
}

