import 'dart:io';
import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/core/storage/token_storage.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/user_dto.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<UserDto>> getCurrentUser() async {
    try {
      // userId로 조회 (API 명세서에 /users/me가 없음)
      final tokenStorage = TokenStorage();
      final userId = await tokenStorage.getUserId();
      
      if (userId == null) {
        return ApiResponse<UserDto>(
          success: false,
          error: ApiError(
            code: 'GET_CURRENT_USER_ERROR',
            message: '사용자 ID를 찾을 수 없습니다. 다시 로그인해주세요.',
          ),
        );
      }
      
      return await getUser(userId);
    } on DioException catch (e) {
      // DioError 처리
      String errorMessage = '사용자 정보를 불러오는데 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 403) {
        errorMessage = '권한이 없습니다.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '사용자를 찾을 수 없습니다.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {
          // 파싱 실패 시 기본 메시지 사용
        }
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = '서버 연결 시간이 초과되었습니다. 네트워크를 확인해주세요.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.';
      }
      
      return ApiResponse<UserDto>(
        success: false,
        error: ApiError(
          code: 'GET_CURRENT_USER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<UserDto>(
        success: false,
        error: ApiError(
          code: 'GET_CURRENT_USER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<UserDto>> getUser(String userId) async {
    try {
      final response = await _apiClient.dio.get('/users/$userId');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<UserDto>(
          success: false,
          error: ApiError(
            code: 'GET_USER_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<UserDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => UserDto.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      String errorMessage = '사용자 정보를 불러오는데 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '사용자를 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<UserDto>(
        success: false,
        error: ApiError(
          code: 'GET_USER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<UserDto>(
        success: false,
        error: ApiError(
          code: 'GET_USER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<UserDto>> updateUser({
    required String userId,
    String? nickname,
    String? statusMessage,
    File? profileImage,
    String? avatarUrl, // 이미지 제거 시 null
  }) async {
    try {
      FormData formData;
      
      if (profileImage != null) {
        // multipart/form-data로 프로필 이미지 포함
        formData = FormData.fromMap({
          if (nickname != null) 'nickname': nickname,
          if (statusMessage != null) 'statusMessage': statusMessage,
          'profileImage': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
        });
      } else {
        // 프로필 이미지 없이 일반 form-data
        formData = FormData.fromMap({
          if (nickname != null) 'nickname': nickname,
          if (statusMessage != null) 'statusMessage': statusMessage,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        });
      }
      
      final response = await _apiClient.dio.put(
        '/users/$userId',
        data: formData,
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<UserDto>(
          success: false,
          error: ApiError(
            code: 'UPDATE_USER_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<UserDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => UserDto.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      String errorMessage = '사용자 정보를 수정하는데 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 403) {
        errorMessage = '권한이 없습니다.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '사용자를 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<UserDto>(
        success: false,
        error: ApiError(
          code: 'UPDATE_USER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<UserDto>(
        success: false,
        error: ApiError(
          code: 'UPDATE_USER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }
}

