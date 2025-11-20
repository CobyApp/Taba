import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/invite_code_dto.dart';

class InviteCodeService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ApiResponse<InviteCodeDto>> generateCode() async {
    try {
      // API 명세서: POST /invite-codes
      final response = await _apiClient.dio.post('/invite-codes');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<InviteCodeDto>(
          success: false,
          error: ApiError(
            code: 'GENERATE_INVITE_CODE_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      print('초대 코드 생성 응답: ${response.statusCode}, ${response.data}');
      
      return ApiResponse<InviteCodeDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) {
          print('초대 코드 생성 응답 data: $data');
          if (data is! Map<String, dynamic>) {
            print('초대 코드 생성: data가 Map이 아님');
            throw Exception('Invalid data format');
          }
          return InviteCodeDto.fromJson(data);
        },
      );
    } on DioException catch (e) {
      print('초대 코드 생성 DioException: ${e.response?.statusCode}, ${e.response?.data}');
      print('요청 URL: ${e.requestOptions.uri}');
      print('요청 메서드: ${e.requestOptions.method}');
      
      String errorMessage = '초대 코드 생성에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '초대 코드 생성 API를 찾을 수 없습니다. 엔드포인트를 확인해주세요.';
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
      
      return ApiResponse<InviteCodeDto>(
        success: false,
        error: ApiError(
          code: 'GENERATE_INVITE_CODE_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<InviteCodeDto>(
        success: false,
        error: ApiError(
          code: 'GENERATE_INVITE_CODE_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<InviteCodeDto?>> getCurrentCode() async {
    try {
      // API 명세서: GET /invite-codes/me
      final response = await _apiClient.dio.get('/invite-codes/me');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<InviteCodeDto?>(
          success: false,
          error: ApiError(
            code: 'GET_INVITE_CODE_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<InviteCodeDto?>.fromJson(
        response.data as Map<String, dynamic>,
        (data) {
          // data가 null일 수 있음 (활성 코드가 없거나 만료된 경우)
          if (data == null) {
            return null;
          }
          return InviteCodeDto.fromJson(data as Map<String, dynamic>);
        },
      );
    } on DioException catch (e) {
      String errorMessage = '초대 코드를 불러오는데 실패했습니다.';
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
      
      return ApiResponse<InviteCodeDto?>(
        success: false,
        error: ApiError(
          code: 'GET_INVITE_CODE_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<InviteCodeDto?>(
        success: false,
        error: ApiError(
          code: 'GET_INVITE_CODE_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }
}

