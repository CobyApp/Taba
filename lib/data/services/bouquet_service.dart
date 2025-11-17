import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/bouquet_dto.dart';

class BouquetService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<List<BouquetDto>>> getBouquets() async {
    try {
      final response = await _apiClient.dio.get('/bouquets');

      return ApiResponse<List<BouquetDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((item) => BouquetDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse<List<BouquetDto>>(
        success: false,
        error: ApiError(
          code: 'GET_BOUQUETS_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<PageResponse<SharedFlowerDto>>> getFriendLetters({
    required String friendId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/bouquets/$friendId/letters',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      return ApiResponse<PageResponse<SharedFlowerDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => PageResponse<SharedFlowerDto>.fromJson(
          data as Map<String, dynamic>,
          (item) => SharedFlowerDto.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      return ApiResponse<PageResponse<SharedFlowerDto>>(
        success: false,
        error: ApiError(
          code: 'GET_FRIEND_LETTERS_ERROR',
          message: e.toString(),
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
