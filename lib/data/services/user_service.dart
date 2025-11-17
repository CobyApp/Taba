import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/user_dto.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<UserDto>> getUser(String userId) async {
    try {
      final response = await _apiClient.dio.get('/users/$userId');

      return ApiResponse<UserDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => UserDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<UserDto>(
        success: false,
        error: ApiError(
          code: 'GET_USER_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<UserDto>> updateUser({
    required String userId,
    String? nickname,
    String? statusMessage,
    String? avatarUrl,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/users/$userId',
        data: {
          if (nickname != null) 'nickname': nickname,
          if (statusMessage != null) 'statusMessage': statusMessage,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
      );

      return ApiResponse<UserDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => UserDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<UserDto>(
        success: false,
        error: ApiError(
          code: 'UPDATE_USER_ERROR',
          message: e.toString(),
        ),
      );
    }
  }
}

