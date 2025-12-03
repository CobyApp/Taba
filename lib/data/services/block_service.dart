import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/block_dto.dart';

/// 차단 API 서비스
/// API 명세서: /blocks
class BlockService {
  final ApiClient _apiClient = ApiClient.instance;

  /// 사용자 차단
  /// POST /blocks/{userId}
  Future<ApiResponse<String>> blockUser(String userId) async {
    try {
      final response = await _apiClient.dio.post('/blocks/$userId');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<String>(
          success: false,
          error: ApiError(
            code: 'BLOCK_USER_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String? ?? '사용자를 차단했습니다.',
      );
    } on DioException catch (e) {
      String errorMessage = '사용자 차단에 실패했습니다.';
      String errorCode = 'BLOCK_USER_ERROR';
      
      if (e.response?.statusCode == 400) {
        // 자기 자신을 차단하려는 경우 또는 이미 차단한 사용자인 경우
        if (e.response?.data != null) {
          try {
            final errorData = e.response!.data as Map<String, dynamic>;
            final error = errorData['error'] as Map<String, dynamic>?;
            errorCode = error?['code'] as String? ?? errorCode;
            errorMessage = error?['message'] as String? ?? errorMessage;
          } catch (_) {}
        }
      } else if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '사용자를 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          errorMessage = error?['message'] as String? ?? 
                        errorData['message'] as String? ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: errorCode,
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'BLOCK_USER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  /// 차단 해제
  /// DELETE /blocks/{userId}
  Future<ApiResponse<String>> unblockUser(String userId) async {
    try {
      final response = await _apiClient.dio.delete('/blocks/$userId');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<String>(
          success: false,
          error: ApiError(
            code: 'UNBLOCK_USER_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String? ?? '차단이 해제되었습니다.',
      );
    } on DioException catch (e) {
      String errorMessage = '차단 해제에 실패했습니다.';
      
      if (e.response?.statusCode == 400) {
        // 차단하지 않은 사용자를 해제하려는 경우
        errorMessage = '차단하지 않은 사용자입니다.';
        if (e.response?.data != null) {
          try {
            final errorData = e.response!.data as Map<String, dynamic>;
            final error = errorData['error'] as Map<String, dynamic>?;
            errorMessage = error?['message'] as String? ?? errorMessage;
          } catch (_) {}
        }
      } else if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          errorMessage = error?['message'] as String? ?? 
                        errorData['message'] as String? ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UNBLOCK_USER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UNBLOCK_USER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  /// 차단한 사용자 목록 조회
  /// GET /blocks
  Future<ApiResponse<List<BlockedUserDto>>> getBlockedUsers() async {
    try {
      final response = await _apiClient.dio.get('/blocks');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<List<BlockedUserDto>>(
          success: false,
          error: ApiError(
            code: 'GET_BLOCKED_USERS_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<List<BlockedUserDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) {
          if (data is List) {
            return data
                .map((item) => BlockedUserDto.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <BlockedUserDto>[];
        },
      );
    } on DioException catch (e) {
      String errorMessage = '차단 목록을 불러오는데 실패했습니다.';
      
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          errorMessage = error?['message'] as String? ?? 
                        errorData['message'] as String? ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<List<BlockedUserDto>>(
        success: false,
        error: ApiError(
          code: 'GET_BLOCKED_USERS_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<List<BlockedUserDto>>(
        success: false,
        error: ApiError(
          code: 'GET_BLOCKED_USERS_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }
}

