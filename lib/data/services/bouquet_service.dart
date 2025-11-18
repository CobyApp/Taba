import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/bouquet_dto.dart';

class BouquetService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<BouquetDto>>> getBouquets() async {
    try {
      final response = await _apiClient.dio.get('/bouquets');

      print('Bouquet API response status: ${response.statusCode}');
      print('Bouquet API response data type: ${response.data.runtimeType}');
      print('Bouquet API response data: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        print('Bouquet API error: Response is not a Map');
        return ApiResponse<List<BouquetDto>>(
          success: false,
          error: ApiError(
            code: 'GET_BOUQUETS_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      print('Bouquet API response keys: ${responseData.keys}');

      return ApiResponse<List<BouquetDto>>.fromJson(
        responseData,
        (data) {
          print('Bouquet API fromJsonT data type: ${data.runtimeType}');
          if (data is List) {
            print('Bouquet API parsing ${data.length} bouquets');
            try {
              return data
                  .map((item) {
                    try {
                      print('Parsing bouquet item: $item');
                      return BouquetDto.fromJson(item as Map<String, dynamic>);
                    } catch (e, stackTrace) {
                      print('Error parsing BouquetDto: $e');
                      print('Stack trace: $stackTrace');
                      print('Item data: $item');
                      rethrow;
                    }
                  })
                  .toList();
            } catch (e, stackTrace) {
              print('Error parsing bouquets list: $e');
              print('Stack trace: $stackTrace');
              return <BouquetDto>[];
            }
          }
          print('Bouquet API error: data is not a List, type: ${data.runtimeType}');
          return <BouquetDto>[];
        },
      );
    } on DioException catch (e) {
      String errorMessage = '꽃다발 목록을 불러오는데 실패했습니다.';
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
      
      return ApiResponse<List<BouquetDto>>(
        success: false,
        error: ApiError(
          code: 'GET_BOUQUETS_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<List<BouquetDto>>(
        success: false,
        error: ApiError(
          code: 'GET_BOUQUETS_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<PageResponse<SharedFlowerDto>>> getFriendLetters({
    required String friendId,
    int page = 0,
    int size = 20,
    String sort = 'sentAt,desc', // 기본값: 최신순
  }) async {
    try {
      // Swagger 명세에 따르면 pageable은 query parameter로 전달
      // Spring의 Pageable은 page, size, sort를 지원
      final response = await _apiClient.dio.get(
        '/bouquets/$friendId/letters',
        queryParameters: {
          'page': page,
          'size': size,
          if (sort.isNotEmpty) 'sort': sort,
        },
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<PageResponse<SharedFlowerDto>>(
          success: false,
          error: ApiError(
            code: 'GET_FRIEND_LETTERS_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<PageResponse<SharedFlowerDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageResponse<SharedFlowerDto>.fromJson(
          data as Map<String, dynamic>,
          (item) => SharedFlowerDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } on DioException catch (e) {
      String errorMessage = '편지 목록을 불러오는데 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '친구를 찾을 수 없습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<PageResponse<SharedFlowerDto>>(
        success: false,
        error: ApiError(
          code: 'GET_FRIEND_LETTERS_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<PageResponse<SharedFlowerDto>>(
        success: false,
        error: ApiError(
          code: 'GET_FRIEND_LETTERS_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<void>> updateBouquetName({
    required String friendId,
    required String bouquetName,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/bouquets/$friendId/name',
        data: {'bouquetName': bouquetName},
      );

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'UPDATE_BOUQUET_NAME_ERROR',
          message: e.toString(),
        ),
      );
    }
  }
}
