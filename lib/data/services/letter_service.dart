import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/letter_dto.dart';
import 'package:taba_app/data/models/letter.dart';

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
      final response = await _apiClient.dio.post(
        '/letters',
        data: {
          'title': title,
          'content': content,
          'preview': preview,
          'flowerType': flowerType,
          'visibility': visibility,
          'isAnonymous': isAnonymous,
          'template': template,
          'attachedImages': attachedImages ?? [],
          'scheduledAt': scheduledAt?.toIso8601String(),
          'recipientId': recipientId,
        },
      );

      return ApiResponse<LetterDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LetterDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<LetterDto>(
        success: false,
        error: ApiError(
          code: 'CREATE_LETTER_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<PageResponse<LetterDto>>> getPublicLetters({
    int page = 0,
    int size = 20,
    String sort = 'sentAt,desc',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/letters/public',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );

      return ApiResponse<PageResponse<LetterDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageResponse<LetterDto>.fromJson(
          data as Map<String, dynamic>,
          (item) => LetterDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      return ApiResponse<PageResponse<LetterDto>>(
        success: false,
        error: ApiError(
          code: 'GET_PUBLIC_LETTERS_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<LetterDto>> getLetter(String letterId) async {
    try {
      final response = await _apiClient.dio.get('/letters/$letterId');

      return ApiResponse<LetterDto>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LetterDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<LetterDto>(
        success: false,
        error: ApiError(
          code: 'GET_LETTER_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<LikeResponse>> likeLetter(String letterId) async {
    try {
      final response = await _apiClient.dio.post('/letters/$letterId/like');

      return ApiResponse<LikeResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LikeResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<LikeResponse>(
        success: false,
        error: ApiError(
          code: 'LIKE_LETTER_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<SaveResponse>> saveLetter(String letterId) async {
    try {
      final response = await _apiClient.dio.post('/letters/$letterId/save');

      return ApiResponse<SaveResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => SaveResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<SaveResponse>(
        success: false,
        error: ApiError(
          code: 'SAVE_LETTER_ERROR',
          message: e.toString(),
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
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'REPORT_LETTER_ERROR',
          message: e.toString(),
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
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'DELETE_LETTER_ERROR',
          message: e.toString(),
        ),
      );
    }
  }
}

class LikeResponse {
  final int likes;
  final bool isLiked;

  LikeResponse({
    required this.likes,
    required this.isLiked,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeResponse(
      likes: json['likes'] as int,
      isLiked: json['isLiked'] as bool,
    );
  }
}

class SaveResponse {
  final int savedCount;
  final bool isSaved;

  SaveResponse({
    required this.savedCount,
    required this.isSaved,
  });

  factory SaveResponse.fromJson(Map<String, dynamic> json) {
    return SaveResponse(
      savedCount: json['savedCount'] as int,
      isSaved: json['isSaved'] as bool,
    );
  }
}
