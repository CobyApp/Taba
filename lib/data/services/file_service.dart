import 'dart:io';
import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';

class FileService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<String>> uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        '/files/upload',
        data: formData,
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<String>(
          success: false,
          error: ApiError(
            code: 'UPLOAD_IMAGE_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['url'] as String,
      );
    } on DioException catch (e) {
      String errorMessage = '이미지 업로드에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 400) {
        errorMessage = '이미지 파일이 올바르지 않습니다.';
      } else if (e.response?.statusCode == 413) {
        errorMessage = '파일 크기가 너무 큽니다. (최대 10MB)';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UPLOAD_IMAGE_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UPLOAD_IMAGE_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<List<String>>> uploadImages(List<File> imageFiles) async {
    final List<String> uploadedUrls = [];
    
    for (final file in imageFiles) {
      final result = await uploadImage(file);
      if (result.isSuccess && result.data != null) {
        uploadedUrls.add(result.data!);
      } else {
        return ApiResponse<List<String>>(
          success: false,
          error: result.error,
        );
      }
    }

    return ApiResponse<List<String>>(
      success: true,
      data: uploadedUrls,
    );
  }
}

