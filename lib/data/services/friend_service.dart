import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/bouquet_dto.dart';

class FriendService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<FriendProfileDto>> addFriendByInviteCode(
    String inviteCode,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/friends/invite',
        data: {'inviteCode': inviteCode},
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<FriendProfileDto>(
          success: false,
          error: ApiError(
            code: 'ADD_FRIEND_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<FriendProfileDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => FriendProfileDto.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      String errorMessage = '친구 추가에 실패했습니다.';
      if (e.response?.statusCode == 400) {
        errorMessage = '유효하지 않은 초대 코드입니다.';
      } else if (e.response?.statusCode == 401) {
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
      
      return ApiResponse<FriendProfileDto>(
        success: false,
        error: ApiError(
          code: 'ADD_FRIEND_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<FriendProfileDto>(
        success: false,
        error: ApiError(
          code: 'ADD_FRIEND_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<List<FriendProfileDto>>> getFriends() async {
    try {
      final response = await _apiClient.dio.get('/friends');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<List<FriendProfileDto>>(
          success: false,
          error: ApiError(
            code: 'GET_FRIENDS_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<List<FriendProfileDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) {
          if (data is List) {
            return data
                .map((item) =>
                    FriendProfileDto.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <FriendProfileDto>[];
        },
      );
    } on DioException catch (e) {
      String errorMessage = '친구 목록을 불러오는데 실패했습니다.';
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
      
      return ApiResponse<List<FriendProfileDto>>(
        success: false,
        error: ApiError(
          code: 'GET_FRIENDS_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<List<FriendProfileDto>>(
        success: false,
        error: ApiError(
          code: 'GET_FRIENDS_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<void>> deleteFriend(String friendId) async {
    try {
      final response = await _apiClient.dio.delete('/friends/$friendId');

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } on DioException catch (e) {
      String errorMessage = '친구 삭제에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '친구 관계를 찾을 수 없습니다.';
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
          code: 'DELETE_FRIEND_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'DELETE_FRIEND_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }
}

