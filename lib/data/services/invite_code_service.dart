import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/invite_code_dto.dart';

class InviteCodeService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<InviteCodeDto>> generateCode() async {
    try {
      final response = await _apiClient.dio.post('/invite-codes/generate');

      return ApiResponse<InviteCodeDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => InviteCodeDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<InviteCodeDto>(
        success: false,
        error: ApiError(
          code: 'GENERATE_INVITE_CODE_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<InviteCodeDto>> getCurrentCode() async {
    try {
      final response = await _apiClient.dio.get('/invite-codes/current');

      return ApiResponse<InviteCodeDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => InviteCodeDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<InviteCodeDto>(
        success: false,
        error: ApiError(
          code: 'GET_INVITE_CODE_ERROR',
          message: e.toString(),
        ),
      );
    }
  }
}

