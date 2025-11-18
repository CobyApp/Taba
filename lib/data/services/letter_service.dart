import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/letter_dto.dart';

class LetterService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<LetterDto>> createLetter({
    required String title,
    required String content,
    required String preview,
    required String flowerType,
    required String visibility,
    bool isAnonymous = false,
    Map<String, dynamic>? template,
    List<String>? attachedImages,
    DateTime? scheduledAt,
    String? recipientId,
  }) async {
    try {
      // 요청 데이터 준비
      final requestData = <String, dynamic>{
        'title': title,
        'content': content,
        'preview': preview,
        'flowerType': flowerType.toUpperCase(), // 대문자로 변환
        'visibility': visibility.toUpperCase(), // 대문자로 변환
        'isAnonymous': isAnonymous,
        if (template != null) 'template': template,
        'attachedImages': attachedImages ?? [],
        if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
        if (recipientId != null) 'recipientId': recipientId,
      };

      final response = await _apiClient.dio.post(
        '/letters',
        data: requestData,
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<LetterDto>(
          success: false,
          error: ApiError(
            code: 'CREATE_LETTER_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<LetterDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LetterDto.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      String errorMessage = '편지 전송에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 400) {
        errorMessage = '편지 정보가 올바르지 않습니다.';
      } else if (e.response?.statusCode == 404 && recipientId != null) {
        errorMessage = '받는 사람을 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<LetterDto>(
        success: false,
        error: ApiError(
          code: 'CREATE_LETTER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<LetterDto>(
        success: false,
        error: ApiError(
          code: 'CREATE_LETTER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<PageResponse<LetterDto>>> getPublicLetters({
    int page = 0,
    int size = 20,
  }) async {
    try {
      // API 명세서에 따르면 page와 size만 지원 (sort 파라미터 없음)
      final response = await _apiClient.dio.get(
        '/letters/public',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<PageResponse<LetterDto>>(
          success: false,
          error: ApiError(
            code: 'GET_PUBLIC_LETTERS_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<PageResponse<LetterDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageResponse<LetterDto>.fromJson(
          data as Map<String, dynamic>,
          (item) => LetterDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      String errorMessage = '편지 목록을 불러오는데 실패했습니다.';
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
      
      return ApiResponse<PageResponse<LetterDto>>(
        success: false,
        error: ApiError(
          code: 'GET_PUBLIC_LETTERS_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<PageResponse<LetterDto>>(
        success: false,
        error: ApiError(
          code: 'GET_PUBLIC_LETTERS_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<LetterDto>> getLetter(String letterId) async {
    try {
      final response = await _apiClient.dio.get('/letters/$letterId');

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<LetterDto>(
          success: false,
          error: ApiError(
            code: 'GET_LETTER_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<LetterDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LetterDto.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      String errorMessage = '편지를 불러오는데 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '편지를 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<LetterDto>(
        success: false,
        error: ApiError(
          code: 'GET_LETTER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<LetterDto>(
        success: false,
        error: ApiError(
          code: 'GET_LETTER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }


  Future<ApiResponse<void>> reportLetter({
    required String letterId,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/letters/$letterId/report',
        data: {'reason': reason},
      );

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } on DioException catch (e) {
      String errorMessage = '신고 처리에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '편지를 찾을 수 없습니다.';
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
          code: 'REPORT_LETTER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'REPORT_LETTER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<void>> deleteLetter(String letterId) async {
    try {
      final response = await _apiClient.dio.delete('/letters/$letterId');

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } on DioException catch (e) {
      String errorMessage = '편지 삭제에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 403) {
        errorMessage = '삭제 권한이 없습니다.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '편지를 찾을 수 없습니다.';
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
          code: 'DELETE_LETTER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'DELETE_LETTER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  /// 편지 답장 (자동 친구 추가)
  /// API 명세서: POST /letters/{letterId}/reply
  /// 답장은 자동으로 DIRECT visibility로 설정됨
  Future<ApiResponse<LetterDto>> replyLetter({
    required String letterId,
    required String title,
    required String content,
    required String preview,
    required String flowerType,
    bool isAnonymous = false,
    Map<String, dynamic>? template,
    List<String>? attachedImages,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'title': title,
        'content': content,
        'preview': preview,
        'flowerType': flowerType.toUpperCase(),
        'visibility': 'DIRECT', // 답장은 항상 DIRECT로 설정
        'isAnonymous': isAnonymous,
        if (template != null) 'template': template,
        'attachedImages': attachedImages ?? [],
      };

      final response = await _apiClient.dio.post(
        '/letters/$letterId/reply',
        data: requestData,
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<LetterDto>(
          success: false,
          error: ApiError(
            code: 'REPLY_LETTER_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<LetterDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LetterDto.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      String errorMessage = '답장 전송에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 400) {
        errorMessage = '답장 정보가 올바르지 않습니다.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '편지를 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<LetterDto>(
        success: false,
        error: ApiError(
          code: 'REPLY_LETTER_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<LetterDto>(
        success: false,
        error: ApiError(
          code: 'REPLY_LETTER_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }
}

