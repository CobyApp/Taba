import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/bouquet_dto.dart';
import 'package:taba_app/data/dto/add_friend_response_dto.dart';

class FriendService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ApiResponse<AddFriendResponseDto>> addFriendByInviteCode(
    String inviteCode,
  ) async {
    try {
      // API 명세서: POST /friends/invite
      final response = await _apiClient.dio.post(
        '/friends/invite',
        data: {'inviteCode': inviteCode},
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<AddFriendResponseDto>(
          success: false,
          error: ApiError(
            code: 'ADD_FRIEND_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      // API 명세서에 따르면 data: { friend: {...}, alreadyFriends: false, isOwnCode: false } 반환
      return ApiResponse<AddFriendResponseDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => AddFriendResponseDto.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      String errorMessage = '친구 추가에 실패했습니다.';
      String? errorCode;
      
      if (e.response?.statusCode == 400) {
        // API 명세서에 따른 구체적인 에러 코드 처리
        if (e.response?.data != null) {
          try {
            final errorData = e.response!.data as Map<String, dynamic>;
            final error = errorData['error'] as Map<String, dynamic>?;
            errorCode = error?['code'] as String?;
            
            // API 명세서에 명시된 에러 코드별 메시지
            switch (errorCode) {
              case 'INVALID_INVITE_CODE':
                errorMessage = '유효하지 않은 초대 코드입니다. (6자리 숫자+영문 조합)';
                break;
              case 'INVITE_CODE_EXPIRED':
                errorMessage = '만료된 초대 코드입니다.';
                break;
              case 'INVITE_CODE_ALREADY_USED':
                errorMessage = '이미 사용된 초대 코드입니다.';
                break;
              case 'CANNOT_USE_OWN_INVITE_CODE':
                errorMessage = '자신의 초대 코드는 사용할 수 없습니다.';
                break;
              case 'ALREADY_FRIENDS':
                errorMessage = '이미 친구 관계입니다.';
                break;
              default:
                errorMessage = error?['message'] as String? ?? 
                              errorData['message'] as String? ?? 
                              '유효하지 않은 초대 코드입니다.';
            }
          } catch (_) {
            errorMessage = '유효하지 않은 초대 코드입니다.';
          }
        } else {
          errorMessage = '유효하지 않은 초대 코드입니다.';
        }
      } else if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          errorCode = error?['code'] as String?;
          errorMessage = error?['message'] as String? ?? 
                        errorData['message'] as String? ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<AddFriendResponseDto>(
        success: false,
        error: ApiError(
          code: 'ADD_FRIEND_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<AddFriendResponseDto>(
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
          // API 명세서: {success: true, data: {friends: [...]}}
          // data는 {friends: [...]} 형태
          if (data is Map<String, dynamic> && data.containsKey('friends')) {
            final friendsList = data['friends'] as List<dynamic>?;
            if (friendsList != null) {
              return friendsList
                .map((item) {
                  final userJson = item as Map<String, dynamic>;
                  // UserDto를 FriendProfileDto로 변환
                  // API 명세서: 친구 목록에는 lastLetterAt 정보가 없음
                  // API 명세서: unreadLetterCount는 안 읽은 개인편지(DIRECT) 개수
                  return FriendProfileDto.fromJson({
                    'id': userJson['id'],
                    'user': userJson, // UserDto 정보 (id, email, nickname, avatarUrl, joinedAt, friendCount, sentLetters)
                    'lastLetterAt': DateTime.now().toIso8601String(), // API 응답에 없으므로 기본값 사용
                    'friendCount': userJson['friendCount'] ?? 0,
                    'sentLetters': userJson['sentLetters'] ?? 0,
                    'unreadLetterCount': userJson['unreadLetterCount'] ?? 0, // API 명세서: 안 읽은 개인편지(DIRECT) 개수
                  });
                })
                .toList();
            }
          }
          // 하위 호환성: data가 직접 배열인 경우
          if (data is List) {
            return data
                .map((item) {
                  final userJson = item as Map<String, dynamic>;
                  return FriendProfileDto.fromJson({
                    'id': userJson['id'],
                    'user': userJson,
                    'lastLetterAt': DateTime.now().toIso8601String(),
                    'friendCount': userJson['friendCount'] ?? 0,
                    'sentLetters': userJson['sentLetters'] ?? 0,
                    'unreadLetterCount': userJson['unreadLetterCount'] ?? 0, // API 명세서: 안 읽은 개인편지(DIRECT) 개수
                  });
                })
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
      // API 명세서: 401 Unauthorized, 404 Not Found - FRIENDSHIP_NOT_FOUND
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        // API 명세서: 404 Not Found - FRIENDSHIP_NOT_FOUND
        errorMessage = '친구 관계를 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          errorMessage = error?['message'] as String? ?? 
                        errorData['message'] as String? ?? 
                        errorData['errorMessage'] as String? ?? 
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

