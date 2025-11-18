import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/bouquet_dto.dart';

class BouquetService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<PageResponse<SharedFlowerDto>>> getFriendLetters({
    required String friendId,
    int page = 0,
    int size = 20,
    String sort = 'sentAt,desc', // 기본값: 최신순
  }) async {
    try {
      // API 명세서: GET /friends/{friendId}/letters?page=0&size=20&sort=sentAt,desc
      // Query Parameters:
      // - page: 페이지 번호 (기본값: 0)
      // - size: 페이지 크기 (기본값: 20)
      // - sort: 정렬 기준 (기본값: sentAt,desc)
      //   - 정렬 필드: sentAt (현재는 sentAt만 지원)
      //   - 정렬 방향: asc, desc
      final response = await _apiClient.dio.get(
        '/friends/$friendId/letters',
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
      // 상세한 에러 로깅
      print('❌ getFriendLetters DioException 발생');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Request URL: ${e.requestOptions.uri}');
      print('   Request Method: ${e.requestOptions.method}');
      print('   Response Data: ${e.response?.data}');
      print('   Error Type: ${e.type}');
      print('   Error Message: ${e.message}');
      
      // 500 에러 등 서버 에러 응답도 ApiResponse 형식으로 올 수 있음
      // {success: false, error: {code, message}} 형식인 경우 파싱 시도
      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          print('   Error Data Type: ${errorData.runtimeType}');
          print('   Error Data Keys: ${errorData.keys}');
          
          // API 명세서에 따른 에러 응답 형식인 경우
          if (errorData.containsKey('success') && errorData['success'] == false) {
            print('✅ getFriendLetters: 서버 에러 응답을 ApiResponse로 변환');
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
          print('❌ getFriendLetters: 에러 응답 파싱 실패: $parseError');
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
        print('⚠️ 서버 500 에러 - API 엔드포인트 확인 필요: /friends/$friendId/letters');
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

}
