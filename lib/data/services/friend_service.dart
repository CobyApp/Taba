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

      return ApiResponse<FriendProfileDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => FriendProfileDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<FriendProfileDto>(
        success: false,
        error: ApiError(
          code: 'ADD_FRIEND_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<List<FriendProfileDto>>> getFriends() async {
    try {
      final response = await _apiClient.dio.get('/friends');

      return ApiResponse<List<FriendProfileDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((item) =>
                FriendProfileDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse<List<FriendProfileDto>>(
        success: false,
        error: ApiError(
          code: 'GET_FRIENDS_ERROR',
          message: e.toString(),
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
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'DELETE_FRIEND_ERROR',
          message: e.toString(),
        ),
      );
    }
  }
}

