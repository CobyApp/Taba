import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/bouquet_dto.dart';

class BouquetService {
  final ApiClient _apiClient = ApiClient();

  // 꽃다발 목록 조회 API 제거됨 (더 이상 사용하지 않음)
  // 친구별 편지 목록은 getFriendLetters로 조회
  @Deprecated('더 이상 사용하지 않음. 친구별 편지 목록은 getFriendLetters 사용')
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

      print('getFriendLetters 원본 응답: ${response.data}');
      print('getFriendLetters 응답 타입: ${response.data.runtimeType}');

      if (response.data is! Map<String, dynamic>) {
        print('getFriendLetters: 응답이 Map이 아님');
        return ApiResponse<PageResponse<SharedFlowerDto>>(
          success: false,
          error: ApiError(
            code: 'GET_FRIEND_LETTERS_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      
      // 응답 파싱 시도
      try {
        return ApiResponse<PageResponse<SharedFlowerDto>>.fromJson(
          responseData,
          (data) {
            print('getFriendLetters data 파싱: $data');
            if (data is! Map<String, dynamic>) {
              print('getFriendLetters: data가 Map이 아님');
              return PageResponse<SharedFlowerDto>(
                content: [],
                page: page,
                size: size,
                totalElements: 0,
                totalPages: 0,
                first: true,
                last: true,
              );
            }
            
            return PageResponse<SharedFlowerDto>.fromJson(
              data,
              (item) {
                try {
                  if (item is! Map<String, dynamic>) {
                    print('getFriendLetters: item이 Map이 아님: $item');
                    throw Exception('Invalid item format');
                  }
                  return SharedFlowerDto.fromJson(item);
                } catch (e, stackTrace) {
                  print('getFriendLetters SharedFlowerDto 파싱 에러: $e');
                  print('Stack trace: $stackTrace');
                  print('Item: $item');
                  rethrow;
                }
              },
            );
          },
        );
      } catch (e, stackTrace) {
        print('getFriendLetters 응답 파싱 에러: $e');
        print('Stack trace: $stackTrace');
        print('Response data: $responseData');
        rethrow;
      }
    } on DioException catch (e) {
      // 500 에러 등 서버 에러 응답도 ApiResponse 형식으로 올 수 있음
      // {success: false, error: {code, message}} 형식인 경우 파싱 시도
      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          
          // API 명세서에 따른 에러 응답 형식인 경우
          if (errorData.containsKey('success') && errorData['success'] == false) {
            print('getFriendLetters: 서버 에러 응답을 ApiResponse로 변환');
            return ApiResponse<PageResponse<SharedFlowerDto>>.fromJson(
              errorData,
              (data) => PageResponse<SharedFlowerDto>(
                content: [],
                page: page,
                size: size,
                totalElements: 0,
                totalPages: 0,
                first: true,
                last: true,
              ),
            );
          }
        } catch (parseError) {
          print('getFriendLetters: 에러 응답 파싱 실패: $parseError');
        }
      }
      
      // 일반적인 에러 처리
      String errorMessage = '편지 목록을 불러오는데 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = '친구를 찾을 수 없습니다.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
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
    } catch (e, stackTrace) {
      print('getFriendLetters 예상치 못한 에러: $e');
      print('Stack trace: $stackTrace');
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
