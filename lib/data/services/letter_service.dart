import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/letter_dto.dart';

class LetterService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ApiResponse<LetterDto>> createLetter({
    required String title,
    required String content,
    required String preview,
    required String visibility,
    Map<String, dynamic>? template,
    List<String>? attachedImages,
    DateTime? scheduledAt, // 예약 발송 기능 제거 (항상 null 전달)
    String? recipientId,
    String? language, // ko, en, ja 중 하나
  }) async {
    try {
      // API 명세서에 따른 요청 데이터 준비
      // - recipientId: DIRECT 편지인 경우 필수
      // - scheduledAt: 예약 발송 시간 (선택사항)
      // - attachedImages: 이미지 URL 배열 (선택사항)
      // - language: 편지 언어 (선택사항). ko, en, ja 중 하나
      final requestData = <String, dynamic>{
        'title': title,
        'content': content,
        'preview': preview,
        'visibility': visibility.toUpperCase(), // PUBLIC, FRIENDS, DIRECT, PRIVATE
        if (template != null) 'template': template,
        if (attachedImages != null && attachedImages.isNotEmpty) 'attachedImages': attachedImages,
        if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
        if (recipientId != null) 'recipientId': recipientId, // DIRECT 편지인 경우 필수
        if (language != null) 'language': language, // ko, en, ja 중 하나
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
        (data) {
          // API 명세서: {success: true, data: {letter: {...}}}
          if (data is Map<String, dynamic> && data.containsKey('letter')) {
            return LetterDto.fromJson(data['letter'] as Map<String, dynamic>);
          }
          // 하위 호환성: data가 직접 letter 객체인 경우
          return LetterDto.fromJson(data as Map<String, dynamic>);
        },
      );
    } on DioException catch (e) {
      String errorMessage = '편지 전송에 실패했습니다.';
      String? errorCode;
      
      // API 명세서: 401 Unauthorized, 400 Bad Request (INVALID_REQUEST, VALIDATION_ERROR), 404 Not Found
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 400) {
        // API 명세서: 400 Bad Request - INVALID_REQUEST, VALIDATION_ERROR
        if (e.response?.data != null) {
          try {
            final errorData = e.response!.data as Map<String, dynamic>;
            final error = errorData['error'] as Map<String, dynamic>?;
            errorCode = error?['code'] as String?;
            
            switch (errorCode) {
              case 'INVALID_REQUEST':
                errorMessage = '편지 정보가 올바르지 않습니다.';
                break;
              case 'VALIDATION_ERROR':
                errorMessage = '입력값 검증에 실패했습니다.';
                break;
              default:
                errorMessage = error?['message'] as String? ?? 
                             errorData['message'] as String? ?? 
                             '편지 정보가 올바르지 않습니다.';
            }
          } catch (_) {
            errorMessage = '편지 정보가 올바르지 않습니다.';
          }
        } else {
          errorMessage = '편지 정보가 올바르지 않습니다.';
        }
      } else if (e.response?.statusCode == 404 && recipientId != null) {
        // API 명세서: 404 Not Found - USER_NOT_FOUND (recipientId가 있는 경우)
        errorMessage = '받는 사람을 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          errorCode = error?['code'] as String?;
          errorMessage = error?['message'] as String? ?? 
                        errorData['message'] as String? ?? 
                        errorData['errorMessage'] as String? ?? 
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
    List<String>? languages, // 언어 필터링 (복수 선택 가능)
  }) async {
    try {
      // API 명세서: GET /letters/public?languages=ko&languages=en&page=0&size=20
      // languages: 여러 언어를 선택하려면 같은 파라미터를 여러 번 사용
      // Dio는 List<String>을 자동으로 ?languages=ko&languages=en 형태로 변환
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
        if (languages != null && languages.isNotEmpty) 'languages': languages,
      };
      
      final response = await _apiClient.dio.get(
        '/letters/public',
        queryParameters: queryParams,
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
        (data) {
          // API 명세서: {success: true, data: {letter: {...}}}
          if (data is Map<String, dynamic> && data.containsKey('letter')) {
            return LetterDto.fromJson(data['letter'] as Map<String, dynamic>);
          }
          // 하위 호환성: data가 직접 letter 객체인 경우
          return LetterDto.fromJson(data as Map<String, dynamic>);
        },
      );
    } on DioException catch (e) {
      String errorMessage = '편지를 불러오는데 실패했습니다.';
      // API 명세서: 401 Unauthorized, 404 Not Found - LETTER_NOT_FOUND
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        // API 명세서: 404 Not Found - LETTER_NOT_FOUND
        errorMessage = '편지를 찾을 수 없습니다.';
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
      // API 명세서: 401 Unauthorized, 404 Not Found - LETTER_NOT_FOUND
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        // API 명세서: 404 Not Found - LETTER_NOT_FOUND
        errorMessage = '편지를 찾을 수 없습니다.';
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
      // API 명세서: 401 Unauthorized, 403 Forbidden (작성자만 삭제 가능), 404 Not Found
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 403) {
        // API 명세서: 403 Forbidden - 작성자만 삭제 가능
        errorMessage = '삭제 권한이 없습니다.';
      } else if (e.response?.statusCode == 404) {
        // API 명세서: 404 Not Found - LETTER_NOT_FOUND
        errorMessage = '편지를 찾을 수 없습니다.';
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
  /// 답장은 자동으로 DIRECT visibility로 설정됨 (서버에서 처리)
  /// 요청에는 visibility를 포함하지 않음
  Future<ApiResponse<LetterDto>> replyLetter({
    required String letterId,
    required String title,
    required String content,
    required String preview,
    Map<String, dynamic>? template,
    List<String>? attachedImages,
    String? language, // ko, en, ja 중 하나
  }) async {
    try {
      final requestData = <String, dynamic>{
        'title': title,
        'content': content,
        'preview': preview,
        // visibility는 포함하지 않음 (서버에서 자동으로 DIRECT로 설정)
        if (template != null) 'template': template,
        if (attachedImages != null && attachedImages.isNotEmpty) 'attachedImages': attachedImages,
        if (language != null) 'language': language, // ko, en, ja 중 하나
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
        (data) {
          // API 명세서: {success: true, data: {letter: {...}}}
          if (data is Map<String, dynamic> && data.containsKey('letter')) {
            return LetterDto.fromJson(data['letter'] as Map<String, dynamic>);
          }
          // 하위 호환성: data가 직접 letter 객체인 경우
          return LetterDto.fromJson(data as Map<String, dynamic>);
        },
      );
    } on DioException catch (e) {
      String errorMessage = '답장 전송에 실패했습니다.';
      String? errorCode;
      
      // API 명세서: 401 Unauthorized, 400 Bad Request (INVALID_REQUEST, VALIDATION_ERROR), 404 Not Found
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 400) {
        // API 명세서: 400 Bad Request - INVALID_REQUEST, VALIDATION_ERROR
        if (e.response?.data != null) {
          try {
            final errorData = e.response!.data as Map<String, dynamic>;
            final error = errorData['error'] as Map<String, dynamic>?;
            errorCode = error?['code'] as String?;
            
            switch (errorCode) {
              case 'INVALID_REQUEST':
                errorMessage = '답장 정보가 올바르지 않습니다.';
                break;
              case 'VALIDATION_ERROR':
                errorMessage = '입력값 검증에 실패했습니다.';
                break;
              default:
                errorMessage = error?['message'] as String? ?? 
                             errorData['message'] as String? ?? 
                             '답장 정보가 올바르지 않습니다.';
            }
          } catch (_) {
            errorMessage = '답장 정보가 올바르지 않습니다.';
          }
        } else {
          errorMessage = '답장 정보가 올바르지 않습니다.';
        }
      } else if (e.response?.statusCode == 404) {
        // API 명세서: 404 Not Found - LETTER_NOT_FOUND
        errorMessage = '편지를 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          errorCode = error?['code'] as String?;
          errorMessage = error?['message'] as String? ?? 
                        errorData['message'] as String? ?? 
                        errorData['errorMessage'] as String? ?? 
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

